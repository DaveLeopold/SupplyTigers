/** Creates the Material Master view for SupplyTigers Data
	2016/06/06
    Dave Leopold
**/

CREATE VIEW supplytigers.vMTRL AS
    SELECT DISTINCT
        Material AS MTRL_ID,
        Material_Description AS MTRL_DESC,
        Brand_Name AS MTRL_BRAND

    FROM
        supplytigers.GraingerIDR