CREATE VIEW supplytigers.vCombinedMaterialMaster AS
    SELECT DISTINCT
        G.Material AS MTRL_ID,
        G.Material_Description AS MTRL_DESC,
        MAX(G.Brand_Name) AS MTRL_BRAND,
        'Grainger' AS Vendor
    FROM
        supplytigers.GraingerIDR G
    GROUP BY 1 , 2 
    UNION SELECT DISTINCT
        K.ITEM_NUM AS MTRL_ID,
        K.ITEM_DESC AS MTRL_DESC,
        K.MFG_DESC AS MTRL_BRAND,
        'Kaman' AS Vendor
    FROM
        supplytigers.KamanYTDSales K 
    UNION SELECT DISTINCT
        O.PRODUCT_Number AS MTRL_ID,
        O.ITEM_DESCRIPTION AS MTRL_DESC,
        NULL AS MTRL_BRAND,
        'Office Depot' AS Vendor
    FROM
        supplytigers.OfficeDepot O 
    UNION SELECT DISTINCT
        ST.SKU AS MTRL_ID,
        ST.ITEM_DESCRIPTION AS MTRL_DESC,
        NULL AS MTRL_BRAND,
        'Staples' AS Vendor
    FROM
        supplytigers.StaplesOrderDetails ST 
    UNION SELECT DISTINCT
        W.SIM AS MTRL_ID,
        W.DESCR AS MTRL_DESC,
        NULL AS MTRL_BRAND,
        'WESCO' AS Vendor
    FROM
        supplytigers.WESCO W
    WHERE
        NAME IS NOT NULL AND ADD1 IS NOT NULL
            AND QTY > 0