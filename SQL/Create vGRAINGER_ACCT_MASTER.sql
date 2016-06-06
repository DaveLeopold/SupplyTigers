/** Create Grainger Account Master view for Supply Tigers accounts
	2016/06/06
    Dave Leopold
**/

CREATE VIEW vGRAINGER_ACCT_MASTER AS
    SELECT DISTINCT
        Acct_Number AS Account_Number,
        Account_Name,
        Address,
        City,
        Region,
        Zip_Code,
        Seller,
        TerrID_CSG,
        TerrID_District_Desc
    FROM
        supplytigers.GraingerAcctMaster