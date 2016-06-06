/** Creates the Grainger Material Hierarchy view for SupplyTigers Data
	2016/06/06
    Dave Leopold
**/

CREATE VIEW supplytigers.vGraingerMaterialHierarchy AS
    SELECT DISTINCT
        Material_Segment AS MTRL_LVL_1,
        Material_Family AS MTRL_LVL_2,
        Grainger_Item_Number AS MTRL_ID
    FROM
        supplytigers.GraingerItemPriceHistory