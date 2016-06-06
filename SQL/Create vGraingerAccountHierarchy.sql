/**	Creates view for the Account Hierarchy for Grainger
	2016/06/03
    Brad Holtzman
**/

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `sa`@`%` 
    SQL SECURITY DEFINER
VIEW `supplytigers`.`vGraingerAccountHierarchy` AS
    SELECT DISTINCT
        `supplytigers`.`GraingerIDR`.`Track_Code` AS `Account_Level_1`,
        `supplytigers`.`GraingerIDR`.`Sub_Track_Code` AS `Account_Level_2`,
        (CASE
            WHEN (`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAC') THEN 'Hormel'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('801639121' , '806374179',
                    '811092725',
                    '818768616',
                    '861271302',
                    '873206981',
                    '882927189',
                    '885817827',
                    '885817828',
                    '885866927',
                    '886090771')))
            THEN
                'Johnsonville'
        END) AS `Account_Level_3`,
        `supplytigers`.`GraingerIDR`.`Account_Number` AS `Account_Number`
    FROM
        `supplytigers`.`GraingerIDR`;
