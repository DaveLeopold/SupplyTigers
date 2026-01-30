# Tesla Negative-Cost Charger for ComEd

Automatically starts your Tesla charging when ComEd real-time electricity
prices go negative — meaning the grid pays you to consume power.

This runs alongside your normal overnight scheduled charging. It only
adds opportunistic charging windows when electricity is literally free
(or better).

## How It Works

1. Polls the [ComEd Hourly Pricing API](https://hourlypricing.comed.com/hp-api/)
   every 5 minutes for the latest real-time price
2. When the price drops below your threshold (default: 0.0 ¢/kWh), it
   sends a `charge_start` command to your Tesla via the Tesla API
3. When the price returns to positive, it stops the session it started
4. It tracks whether *it* started the session, so it won't interfere
   with your normal scheduled charging or a session you started manually

## Prerequisites

- Python 3.10+
- A Tesla vehicle on your Tesla account
- Enrolled in [ComEd Hourly Pricing](https://hourlypricing.comed.com/)
- Vehicle must be plugged in for charging to start

## Setup

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Create your config file

```bash
cp config.example.json config.json
```

Edit `config.json` with your details:

```json
{
    "tesla_email": "your-tesla-account@email.com",
    "vehicle_index": 0,
    "price_threshold_cents": 0.0,
    "poll_interval_seconds": 300,
    "max_battery_percent": 90
}
```

| Field | Description |
|-------|-------------|
| `tesla_email` | Email for your Tesla account |
| `vehicle_index` | Which vehicle to control (0 = first) |
| `price_threshold_cents` | Price in ¢/kWh to trigger charging. `0.0` = only negative prices. Set to e.g. `1.0` to also catch very cheap windows |
| `poll_interval_seconds` | How often to check prices. 300 (5 min) matches the ComEd update interval |
| `max_battery_percent` | Stop charging when battery reaches this level |

### 3. Authorize with Tesla (first run only)

```bash
python negative_cost_charger.py
```

On the first run, a browser window opens to log in to your Tesla account.
After login, paste the resulting URL back into the terminal. Your token
is cached locally so you won't need to do this again.

## Running

### Foreground

```bash
python negative_cost_charger.py
```

### With debug logging

```bash
python negative_cost_charger.py --debug
```

### As a systemd service (Linux)

Create `/etc/systemd/system/tesla-neg-charger.service`:

```ini
[Unit]
Description=Tesla Negative-Cost Charger
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/tesla-negative-cost-charger
ExecStart=/usr/bin/python3 negative_cost_charger.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl enable tesla-neg-charger
sudo systemctl start tesla-neg-charger
sudo journalctl -u tesla-neg-charger -f   # view logs
```

## Notes

- ComEd negative prices are uncommon but do occur, typically during
  overnight hours with high wind generation and low demand
- The script will not wake your car or start charging if it's unplugged
- Tesla API commands are billed per-use since Feb 2025 — at a 5-minute
  poll interval, the cost is negligible (status checks are free, only
  start/stop commands incur a charge)
- The script gracefully stops any active session on Ctrl+C
