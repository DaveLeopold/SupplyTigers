Create view  supplytigers.vCombinedAccountMaster as
SELECT DISTINCT
    G.Acct_Number AS Account_Number,
    G.Account_Name AS Account_Name,
    G.Address AS Address,
    G.City AS City,
    G.Region AS Region,
    G.Zip_Code AS Zip_Code,
--  G.Seller AS Seller,
--  G.TerrID_CSG AS TerrID_CSG,
--  G.TerrID_District_Desc AS TerrID_District_Desc,
    'Grainger' AS Vendor
FROM
    supplytigers.GraingerAcctMaster G 
UNION SELECT DISTINCT
    K.CUST_ID AS Account_Number,
    K.COMPANYNAME AS Account_Name,
    K.ADDR_1 AS Address,
    K.FACILITY AS City,
    K.STATE AS Region,
    NULL AS Zip_Code,
--  K.SLSMN_NAME AS Seller,
--  NULL AS TerrID_CSG,
--  K.branch_name AS TerrID_District_Desc,
    'Kaman' AS Vendor
FROM
    supplytigers.KamanYTDSales K 
UNION SELECT DISTINCT
    O.ACCT_Number AS Account_Number,
    O.ACCT_NAME AS Account_Name,
    O.ADDRESS AS Address,
    O.CITY AS City,
    O.ST AS Region,
    O.ZIP AS Zip_Code,
--  CONCAT(O.FIRST_NAME, ' ', O.LAST_NAME) AS Seller,
--  NULL AS TerrID_CSG,
--  NULL AS TerrID_District_Desc,
    'Office Depot' AS Vendor
FROM
    supplytigers.OfficeDepot O 
UNION SELECT DISTINCT
    ST.Master_Customer_Number AS Account_Number,
    ST.Master_Customer_Name AS Account_Name,
    ST.Ship_To_Line1_Address AS Address,
    ST.Ship_To_City AS City,
    ST.Ship_To_State AS Region,
    ST.Ship_To_Zip AS Zip_Code,
--  ST.Order_Contact AS Seller,
--  NULL AS TerrID_CSG,
--  NULL AS TerrID_District_Desc,
    'Staples' AS Vendor
FROM
    supplytigers.StaplesOrderDetails ST 
UNION SELECT DISTINCT
    W.BR AS Account_Number,
    W.NAME AS Account_Name,
    W.ADD1 AS Address,
    W.CITY AS City,
    W.STATE AS Region,
    W.ZIP AS Zip_Code,
--  NULL AS Seller,
--  NULL AS TerrID_CSG,
--  NULL AS TerrID_District_Desc,
    'WESCO' AS Vendor
FROM
    supplytigers.WESCO W
WHERE
    NAME IS NOT NULL AND ADD1 IS NOT NULL

