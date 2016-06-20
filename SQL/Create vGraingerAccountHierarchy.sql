/**	Creates view for the Account Hierarchy for Grainger
	2016/06/20
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
            WHEN (`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAE') THEN 'Tillamook'
            WHEN (`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGOB') THEN 'Bluestem'
            WHEN (`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGSE') THEN 'Service Experts'
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
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('827996042' , '808915102',
                    '808915102',
                    '827996042',
                    '808915102',
                    '808915102',
                    '827996042',
                    '827996042',
                    '809402290',
                    '860196005')))
            THEN
                'Alcami'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '861624112'))
            THEN
                'ASAP Industries'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('824880892' , '801256108')))
            THEN
                'Bluestem'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '882602568'))
            THEN
                'Cumberland Dairy'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '885092304'))
            THEN
                'Dynagrid Construction Group Llc'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '882086135'))
            THEN
                'Fosbel Ceramics'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('800198079' , '862861663', '878212828', '804428696')))
            THEN
                'Gulbrandsen'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '826710147'))
            THEN
                'Ind Spec Chemical'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('801576430' , '857436208')))
            THEN
                'Kronos'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('8818501306' , '821728649', '808798185')))
            THEN
                'Neil Jones'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '838354173'))
            THEN
                'Permian Plastics'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '873640643'))
            THEN
                'Qualitech'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` IN ('839037330' , '837501279')))
            THEN
                'Rhea Cattle Co'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '806464590'))
            THEN
                'Sailor Plastics'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '886094615'))
            THEN
                'Service Experts'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '801681131'))
            THEN
                'Smith Brothers'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '836981332'))
            THEN
                'Stainless Sales'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '885920283'))
            THEN
                'Supply Tigers'
            WHEN
                ((`supplytigers`.`GraingerIDR`.`Sub_Track_Code` = 'STGAB')
                    AND (`supplytigers`.`GraingerIDR`.`Account_Number` = '800932006'))
            THEN
                'Weetabix'
        END) AS `Account_Level_3`,
        `supplytigers`.`GraingerIDR`.`Account_Number` AS `Account_Number`
    FROM
        `supplytigers`.`GraingerIDR`;
