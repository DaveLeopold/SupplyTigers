#!/usr/bin/env python3
"""
Tesla Negative-Cost Charger for ComEd Hourly Pricing

Monitors ComEd real-time electricity prices and automatically starts
Tesla charging when prices go negative (i.e., the grid is paying you
to consume electricity). Stops the negative-cost charging session when
prices return to positive.

This does NOT interfere with your normal scheduled overnight charging —
it only adds opportunistic charging during negative price windows.

Usage:
    python negative_cost_charger.py
    python negative_cost_charger.py --config /path/to/config.json
"""

import argparse
import json
import logging
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests
import teslapy

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
COMED_5MIN_API = "https://hourlypricing.comed.com/api?type=5minutefeed"
COMED_HOUR_AVG_API = "https://hourlypricing.comed.com/api?type=currenthouraverage"

DEFAULT_CONFIG_PATH = Path(__file__).parent / "config.json"
DEFAULT_POLL_INTERVAL_SECONDS = 300  # 5 minutes (matches ComEd update cadence)
DEFAULT_PRICE_THRESHOLD = 0.0       # cents/kWh — trigger at negative prices
HIGH_BATTERY_THRESHOLD = 79         # skip checking car when battery >= this
HIGH_BATTERY_COOLDOWN = 3600        # seconds to wait before rechecking (1 hour)
MIN_CHARGE_DURATION = 900           # seconds — keep charging at least 15 minutes
CHARGE_GRACE_PRICE = 3.0            # ¢/kWh — allow charging up to this during the 15-min window
UNPLUGGED_COOLDOWN = 900            # seconds — skip car checks for 15 min when unplugged

LOG_FORMAT = "%(asctime)s [%(levelname)s] %(message)s"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)
logger = logging.getLogger("negative_cost_charger")


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
def load_config(path: str | None = None) -> dict:
    """Load configuration from a JSON file."""
    config_path = Path(path) if path else DEFAULT_CONFIG_PATH
    if not config_path.exists():
        logger.error("Config file not found: %s", config_path)
        logger.error("Copy config.example.json to config.json and fill in your details.")
        sys.exit(1)

    with open(config_path) as f:
        config = json.load(f)

    # Validate required fields
    required = ["tesla_email"]
    for field in required:
        if field not in config or not config[field]:
            logger.error("Missing required config field: %s", field)
            sys.exit(1)

    return config


# ---------------------------------------------------------------------------
# ComEd Price Monitoring
# ---------------------------------------------------------------------------
def get_comed_current_price() -> float | None:
    """
    Fetch the latest 5-minute price from ComEd Hourly Pricing API.

    Returns the price in cents per kWh, or None on failure.
    """
    try:
        resp = requests.get(COMED_5MIN_API, timeout=30)
        resp.raise_for_status()
        data = resp.json()

        if not data:
            logger.warning("ComEd API returned empty data")
            return None

        # The API returns a list sorted newest-first.
        # Each entry: {"millisUTC": "...", "price": "2.5"}
        latest = data[0]
        price = float(latest["price"])
        timestamp_ms = int(latest["millisUTC"])
        timestamp = datetime.fromtimestamp(timestamp_ms / 1000, tz=timezone.utc)

        logger.info(
            "ComEd price: %.2f ¢/kWh (as of %s UTC)",
            price,
            timestamp.strftime("%Y-%m-%d %H:%M"),
        )
        return price

    except requests.RequestException as e:
        logger.error("Failed to fetch ComEd price: %s", e)
        return None
    except (KeyError, ValueError, IndexError) as e:
        logger.error("Failed to parse ComEd response: %s", e)
        return None


# ---------------------------------------------------------------------------
# Tesla Vehicle Control
# ---------------------------------------------------------------------------
class TeslaChargeController:
    """Controls Tesla vehicle charging via the Tesla API."""

    def __init__(self, email: str, vehicle_index: int = 0):
        self.email = email
        self.vehicle_index = vehicle_index
        self._tesla = None
        self._vehicle = None

    def _get_tesla(self) -> teslapy.Tesla:
        if self._tesla is None:
            self._tesla = teslapy.Tesla(self.email)
            if not self._tesla.authorized:
                logger.info("Tesla authorization required. Opening browser...")
                print("\n" + "=" * 60)
                print("TESLA AUTHORIZATION REQUIRED")
                print("=" * 60)
                print("A browser window will open for you to log in to your")
                print("Tesla account. After logging in, paste the resulting")
                print("URL back here.")
                print("=" * 60 + "\n")
                self._tesla.fetch_token(authorization_response=input("Enter URL: "))
        return self._tesla

    def _get_vehicle(self) -> teslapy.Vehicle:
        if self._vehicle is None:
            tesla = self._get_tesla()
            vehicles = tesla.vehicle_list()
            if not vehicles:
                logger.error("No Tesla vehicles found on this account")
                sys.exit(1)
            if self.vehicle_index >= len(vehicles):
                logger.error(
                    "Vehicle index %d out of range (found %d vehicles)",
                    self.vehicle_index,
                    len(vehicles),
                )
                sys.exit(1)
            self._vehicle = vehicles[self.vehicle_index]
            logger.info(
                "Selected vehicle: %s (%s)",
                self._vehicle["display_name"],
                self._vehicle["vin"],
            )
        return self._vehicle

    def _wake_vehicle(self) -> bool:
        """Wake the vehicle if it's asleep. Returns True if online."""
        vehicle = self._get_vehicle()
        try:
            vehicle.sync_wake_up(timeout=60)
            return True
        except teslapy.VehicleError as e:
            logger.error("Failed to wake vehicle: %s", e)
            return False

    def is_plugged_in(self) -> bool:
        """Check if the vehicle is plugged in."""
        vehicle = self._get_vehicle()
        try:
            charge_state = vehicle.get_vehicle_data()["charge_state"]
            state = charge_state.get("charging_state", "")
            # Possible states: Disconnected, Stopped, Charging, Complete
            plugged_in = state != "Disconnected"
            logger.info("Charging state: %s (plugged in: %s)", state, plugged_in)
            return plugged_in
        except Exception as e:
            logger.error("Failed to get charge state: %s", e)
            return False

    def is_currently_charging(self) -> bool:
        """Check if the vehicle is currently charging."""
        vehicle = self._get_vehicle()
        try:
            charge_state = vehicle.get_vehicle_data()["charge_state"]
            return charge_state.get("charging_state") == "Charging"
        except Exception as e:
            logger.error("Failed to get charge state: %s", e)
            return False

    def get_battery_level(self) -> int | None:
        """Get current battery percentage."""
        vehicle = self._get_vehicle()
        try:
            charge_state = vehicle.get_vehicle_data()["charge_state"]
            return charge_state.get("battery_level")
        except Exception as e:
            logger.error("Failed to get battery level: %s", e)
            return None

    def get_charge_info(self) -> dict | None:
        """Get battery level and plug state in a single API call."""
        vehicle = self._get_vehicle()
        try:
            charge_state = vehicle.get_vehicle_data()["charge_state"]
            state = charge_state.get("charging_state", "")
            return {
                "battery_level": charge_state.get("battery_level"),
                "plugged_in": state != "Disconnected",
                "charging_state": state,
            }
        except Exception as e:
            logger.error("Failed to get charge info: %s", e)
            return None

    def start_charging(self) -> bool:
        """Send the charge_start command."""
        vehicle = self._get_vehicle()
        if not self._wake_vehicle():
            return False
        try:
            vehicle.command("START_CHARGE")
            logger.info("Charging STARTED")
            return True
        except teslapy.VehicleError as e:
            logger.warning("Could not start charging: %s", e)
            return False

    def stop_charging(self) -> bool:
        """Send the charge_stop command."""
        vehicle = self._get_vehicle()
        if not self._wake_vehicle():
            return False
        try:
            vehicle.command("STOP_CHARGE")
            logger.info("Charging STOPPED")
            return True
        except teslapy.VehicleError as e:
            logger.warning("Could not stop charging: %s", e)
            return False


# ---------------------------------------------------------------------------
# Main Loop
# ---------------------------------------------------------------------------
def run(config: dict) -> None:
    """Main monitoring loop."""
    poll_interval = config.get("poll_interval_seconds", DEFAULT_POLL_INTERVAL_SECONDS)
    threshold = config.get("price_threshold_cents", DEFAULT_PRICE_THRESHOLD)
    vehicle_index = config.get("vehicle_index", 0)
    max_battery = config.get("max_battery_percent", 100)

    controller = TeslaChargeController(
        email=config["tesla_email"],
        vehicle_index=vehicle_index,
    )

    # Track whether WE started a charging session (to avoid stopping
    # a session the user started manually or via scheduled charging).
    negative_cost_session_active = False

    # High-battery cooldown: when battery >= 79%, skip checking the car
    # for 1 hour. Reset if the car is freshly plugged in.
    high_battery_skip_until = 0.0  # unix timestamp; 0 = no cooldown
    last_plugged_in = None         # previous plug state for transition detection

    # Unplugged cooldown: when car is not plugged in, skip checking for
    # 15 minutes. Reset if the car is freshly plugged in.
    unplugged_skip_until = 0.0     # unix timestamp; 0 = no cooldown

    # Minimum charge session: once charging starts, keep going for at least
    # 15 minutes as long as price stays <= 3.0 ¢/kWh.
    session_started_at = 0.0       # unix timestamp when we started charging

    logger.info("=" * 60)
    logger.info("Tesla Negative-Cost Charger")
    logger.info("=" * 60)
    logger.info("Tesla account   : %s", config["tesla_email"])
    logger.info("Price threshold : %.2f ¢/kWh", threshold)
    logger.info("Poll interval   : %d seconds", poll_interval)
    logger.info("Max battery %%   : %d%%", max_battery)
    logger.info("High bat skip   : >= %d%% → wait 1 hour", HIGH_BATTERY_THRESHOLD)
    logger.info("=" * 60)

    while True:
        try:
            price = get_comed_current_price()

            if price is None:
                logger.warning("Skipping cycle — could not fetch price")
                time.sleep(poll_interval)
                continue

            price_is_negative = price < threshold

            if price_is_negative and not negative_cost_session_active:
                # Price just went negative — start charging if possible
                logger.info(
                    "Price (%.2f ¢) is below threshold (%.2f ¢) — "
                    "attempting to start charging",
                    price,
                    threshold,
                )

                # Check if we're in a cooldown period (high battery or unplugged)
                now = time.time()
                in_cooldown = (
                    now < high_battery_skip_until or now < unplugged_skip_until
                )

                if in_cooldown:
                    # Cooldown active — but check if the car was just plugged in
                    info = controller.get_charge_info()
                    if info is None:
                        time.sleep(poll_interval)
                        continue

                    just_plugged_in = (
                        last_plugged_in is not None
                        and not last_plugged_in
                        and info["plugged_in"]
                    )
                    last_plugged_in = info["plugged_in"]

                    if just_plugged_in:
                        logger.info(
                            "Car just plugged in — clearing cooldowns"
                        )
                        high_battery_skip_until = 0.0
                        unplugged_skip_until = 0.0
                        # Fall through to normal battery check below
                    else:
                        if now < unplugged_skip_until:
                            remaining = int(unplugged_skip_until - now)
                            label = "Unplugged"
                        else:
                            remaining = int(high_battery_skip_until - now)
                            label = "High-battery"
                        logger.info(
                            "%s cooldown active — skipping car check "
                            "(%d min %d sec remaining)",
                            label,
                            remaining // 60,
                            remaining % 60,
                        )
                        time.sleep(poll_interval)
                        continue

                # Normal path: check plug + battery state
                info = controller.get_charge_info()
                if info is None:
                    time.sleep(poll_interval)
                    continue

                last_plugged_in = info["plugged_in"]

                if not info["plugged_in"]:
                    unplugged_skip_until = time.time() + UNPLUGGED_COOLDOWN
                    logger.info(
                        "Vehicle is not plugged in — skipping car checks "
                        "for 15 minutes"
                    )
                    time.sleep(poll_interval)
                    continue

                battery = info["battery_level"]
                if battery is not None and battery >= max_battery:
                    logger.info(
                        "Battery at %d%% (max %d%%) — skipping",
                        battery,
                        max_battery,
                    )
                    time.sleep(poll_interval)
                    continue

                if battery is not None and battery >= HIGH_BATTERY_THRESHOLD:
                    logger.info(
                        "Battery at %d%% (>= %d%%) — skipping car checks "
                        "for 1 hour",
                        battery,
                        HIGH_BATTERY_THRESHOLD,
                    )
                    high_battery_skip_until = time.time() + HIGH_BATTERY_COOLDOWN
                    time.sleep(poll_interval)
                    continue

                if controller.start_charging():
                    negative_cost_session_active = True
                    session_started_at = time.time()
                    logger.info("Negative-cost charging session STARTED")

            elif not price_is_negative and negative_cost_session_active:
                # Price returned to positive — but respect the 15-min minimum
                elapsed = time.time() - session_started_at
                in_grace_period = elapsed < MIN_CHARGE_DURATION
                price_acceptable = price <= CHARGE_GRACE_PRICE

                if in_grace_period and price_acceptable:
                    remaining = int(MIN_CHARGE_DURATION - elapsed)
                    logger.info(
                        "Price (%.2f ¢) is positive but within 15-min minimum "
                        "and <= %.1f ¢ — continuing (%d min %d sec left)",
                        price,
                        CHARGE_GRACE_PRICE,
                        remaining // 60,
                        remaining % 60,
                    )
                else:
                    if in_grace_period and not price_acceptable:
                        logger.info(
                            "Price (%.2f ¢) exceeded %.1f ¢ ceiling — "
                            "stopping despite 15-min minimum",
                            price,
                            CHARGE_GRACE_PRICE,
                        )
                    else:
                        logger.info(
                            "Price (%.2f ¢) is above threshold (%.2f ¢) — "
                            "stopping negative-cost session",
                            price,
                            threshold,
                        )
                    if controller.stop_charging():
                        negative_cost_session_active = False
                        session_started_at = 0.0
                        logger.info("Negative-cost charging session ENDED")

            elif negative_cost_session_active:
                # Still negative — check battery cap
                battery = controller.get_battery_level()
                if battery is not None and battery >= max_battery:
                    logger.info(
                        "Battery reached %d%% (max %d%%) — ending session",
                        battery,
                        max_battery,
                    )
                    if controller.stop_charging():
                        negative_cost_session_active = False
                        session_started_at = 0.0
                else:
                    logger.info("Negative-cost session active — continuing")

            else:
                logger.info("Price is positive — waiting")

        except KeyboardInterrupt:
            logger.info("Shutting down...")
            if negative_cost_session_active:
                logger.info("Stopping active charging session before exit")
                controller.stop_charging()
            break
        except Exception as e:
            logger.error("Unexpected error: %s", e, exc_info=True)

        time.sleep(poll_interval)


# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Auto-charge Tesla when ComEd prices go negative"
    )
    parser.add_argument(
        "--config",
        type=str,
        default=None,
        help="Path to config.json (default: config.json in script directory)",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug logging",
    )
    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    config = load_config(args.config)
    run(config)


if __name__ == "__main__":
    main()
