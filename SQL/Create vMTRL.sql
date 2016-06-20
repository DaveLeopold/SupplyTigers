/** Creates the Material Master view for SupplyTigers Data
	2016/06/06
    Dave Leopold
**/

        
CREATE 
   
VIEW `supplytigers`.`vMTRL` AS
    SELECT DISTINCT
        `supplytigers`.`GraingerIDR`.`Material` AS `MTRL_ID`,
        `supplytigers`.`GraingerIDR`.`Material_Description` AS `MTRL_DESC`,
        MAX(`supplytigers`.`GraingerIDR`.`Brand_Name`) AS `MTRL_BRAND`
    FROM
        `supplytigers`.`GraingerIDR`
    GROUP BY 1 , 2;
