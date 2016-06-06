/** Creates the Material Master view for SupplyTigers Data
	2016/06/06
    Dave Leopold
**/

CREATE VIEW supplytigers.vMTRL AS
    SELECT DISTINCT
        IDR.Material AS MTRL_ID,
        IDR.Material_Description AS MTRL_DESC,
        IDR.Brand_Name AS MTRL_BRAND,
        IPH.Material_Segment AS MTRL_SEGMENT,
        IPH.Material_Family AS MTRL_FAMILY
    FROM
        supplytigers.GraingerIDR IDR
            LEFT JOIN
        supplytigers.GraingerItemPriceHistory IPH ON IDR.Material = IPH.Grainger_Item_Number

