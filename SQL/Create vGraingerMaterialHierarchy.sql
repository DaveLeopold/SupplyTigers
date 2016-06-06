/** Creates the Grainger Material Hierarchy view for SupplyTigers Data
	2016/06/06
    Dave Leopold
**/

CREATE VIEW supplytigers.vGraingerMaterialHierarchy AS
    SELECT DISTINCT
        Grainger_Item_Number AS MTRL_ID,
        Material_Segment,
        Material_Family
    FROM
        supplytigers.GraingerItemPriceHistory