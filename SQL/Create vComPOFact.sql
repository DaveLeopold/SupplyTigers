-- CREATE VIEW supplytigers.vCombined_PO_FACT AS
    SELECT DISTINCT
        G.
        'Grainger' AS Vendor
    FROM
        supplytigers.GraingerIDR G
    
    UNION SELECT DISTINCT
        K.
        'Kaman' AS Vendor
    FROM
        supplytigers.KamanYTDSales K 
    
    UNION SELECT DISTINCT
        O.
        'Office Depot' AS Vendor
    FROM
        supplytigers.OfficeDepot O 
        
    UNION SELECT DISTINCT
        ST.
        'Staples' AS Vendor
    FROM
        supplytigers.StaplesOrderDetails ST 
        
    UNION SELECT DISTINCT
        W.
        'WESCO' AS Vendor
    FROM
        supplytigers.WESCO W
    WHERE
        NAME IS NOT NULL AND ADD1 IS NOT NULL
            