				-- Membership Active
				select distinct
				e.complex_name cinema,
				cast(person_creationDate as date) date_filter,
				membership_id,
				CONCAT(person_birthdayDate, '-', person_birthdayMonth, '-', REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) as DOB,
				case when ISNULL(CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')),'') = '' then -1 else YEAR(GETDATE()) - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) end AS AGE_SUPPLIED
				from cognetic_data_transaction a 
				join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
				left join cognetic_campaigns_complex e on a.transaction_complexid = e.complex_id
				join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
				INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
				LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id and transaction_cardNumber = card_cardNumber
				LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
				INNER JOIN cognetic_members_club ON membership_clubid = club_id
				WHERE ISNULL(membership_deleted,0) = 0 
				and person_town in (N'Thành phố Bà Rịa',N'Bà Rịa', 'Ba Ria')
                and person_creationDate >= '2023-10-01 00:00:00'
				
				
				-- member co giao dich
				select distinct
				membership_id,
				e.complex_name cinema,
				person_email,
				person_mobilePhone,
				person_creationDate,
				membership_id,
				CONCAT(person_birthdayDate, '-', person_birthdayMonth, '-', REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) as DOB,
				case when ISNULL(CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')),'') = '' then -1 else YEAR(GETDATE()) - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) end AS AGE_SUPPLIED
				from cognetic_data_transaction a 
				join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
				left join cognetic_campaigns_complex e on a.transaction_complexid = e.complex_id
				join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
				INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
				LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id and transaction_cardNumber = card_cardNumber
				LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
				INNER JOIN cognetic_members_club ON membership_clubid = club_id
				WHERE ISNULL(membership_deleted,0) = 0 
				and cast(person_creationDate as date) >= cast(getdate()-1 as date)



				-- Membership được tạo kể cả có gd hay không
                select
				membership_id,
				person_creationDate,
				case when isnull(person_town,'') = '' then 'Unknown' else person_town end person_town,
				CONCAT(person_birthdayDate, '-', person_birthdayMonth, '-', REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) as DOB,
				case when ISNULL(CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')),'') = '' then -1 else YEAR(GETDATE()) - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) end AS AGE_SUPPLIED
				from cognetic_members_membership d
				INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
				LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
				INNER JOIN cognetic_members_club ON membership_clubid = club_id
				WHERE ISNULL(membership_deleted,0) = 0 
                and person_creationDate >= '2023-10-01 00:00:00'
				
				
				
				
				-- Membership nhieu thông tin hơn 
				

declare @memberid nvarchar(100), @fromdate datetime, @todate datetime 
set @memberid = 'JRF951MR25'
set @fromdate = '2024-08-01 00:00:00.000'
set @todate = '2024-09-01 00:00:00.000'

select 
transaction_id,
transaction_POStransactionId transNumber_Site,
complex_name,
d.membership_id,
CONCAT(person_birthdayDate, '-', person_birthdayMonth, '-', REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')) as DOB,
concat(person_firstName, ' ',person_lastName) fullName,
person_gender,
person_email,
person_mobilePhone,
a.transaction_time,
case when transactionItem_movieid is null then 	sum(transactionItem_quantity) else 0 end co_quantity,
case when transactionItem_movieid is not null then 	sum(transactionItem_quantity) else 0 end bo_quantity,
	case when transactionItem_movieid is null then 	(sum(case when transactionItem_quantity < 0 then transactionItem_spend * transactionItem_quantity else transactionItem_spend end) + sum(case when transactionItem_quantity < 0 then transactionItem_tax * transactionItem_quantity else transactionItem_tax end))  else 0 end  CO_amount,
case when transactionItem_movieid is not null then 	(sum(case when transactionItem_quantity < 0 then transactionItem_spend * transactionItem_quantity else transactionItem_spend end) + sum(case when transactionItem_quantity < 0 then transactionItem_tax * transactionItem_quantity else transactionItem_tax end)) else 0 end  BO_amount
from cognetic_data_transaction a 
join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
left join cognetic_campaigns_complex e on a.transaction_complexid = e.complex_id
left join cognetic_rules_movie c on b.transactionItem_movieid = c.movie_id
left join cognetic_data_item f on b.transactionItem_itemid = f.item_id
join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id  and transaction_cardEntry = card_membershipid
LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
INNER JOIN cognetic_members_club ON membership_clubid = club_id
WHERE ISNULL(membership_deleted,0) = 0 
and transaction_time >= @fromdate
and transaction_time < @todate
and membership_id = @memberid
group by 		
complex_name,
transaction_POStransactionId,
transaction_id,
d.membership_id,
CONCAT(person_birthdayDate, '-', person_birthdayMonth, '-', REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20')),
concat(person_firstName, ' ',person_lastName) ,
person_gender,
person_email,
person_mobilePhone,
a.transaction_time,
transactionItem_movieid
					
					
					
					-- point membership 
					
					SELECT
                                        membership_id,
                                        transactionMembershipBalance_pointsEarnedApplied point_earned,
                                        transactionMembershipBalance_points_used point_used
                                    FROM 
                                        cognetic_data_transaction cdt WITH (NOLOCK)
                                    JOIN cognetic_members_membership cmm WITH (NOLOCK) ON
                                        cdt.transaction_membershipid = cmm.membership_id
                                    join cognetic_data_transactionMembershipBalance b on
                                        cdt.transaction_id = b.transactionMembershipBalance_transaction_id
                                    where
                                        transactionMembershipBalance_balanceType_id = 7
                                        AND
                                        transaction_time >= '2024-01-01 00:00:00.000'
										
										
										
-- point membership lũy kế theo transaction 
select *
from 
(
SELECT membership_id,a.transaction_time,transaction_id,transactionMembershipBalance_pointsCurrentBalance,transactionMembershipBalance_pointsEarnedApplied,
row_number() over (partition by membership_id order by transaction_time desc, transactionMembershipBalance_SequenceNo desc) row 
-- 	membership_levelid,
-- 	sum(transactionMembershipBalance_pointsEarnedApplied) point_earned,
-- 	sum(transactionMembershipBalance_points_used) point_used 
FROM
	cognetic_data_transaction a WITH ( NOLOCK )
	JOIN cognetic_data_transactionMembershipBalance b ON a.transaction_id = b.transactionMembershipBalance_transaction_id 
	join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
	INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
	LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id  and transaction_cardEntry = card_membershipid
	LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
	INNER JOIN cognetic_members_club ON membership_clubid = club_id
	WHERE ISNULL(membership_deleted,0) = 0 
	and transactionMembershipBalance_balanceType_id = 7 
	AND transaction_time >= '2023-01-01 00:00:00.000'
	AND transaction_time < '2024-01-01 00:00:00.000'
	and membership_levelid = 5
	) A 
where A.row = 1
	


					
					
					-- membership age range 
Declare @year int, @fromdate datetime, @todate datetime 
set @year = 2022
set @fromdate = '2022-01-01 00:00:00.000'
set @todate = '2023-01-01 00:00:00.000'

select 
A.Quarter,	A.Age, sum(A.numbUser) numUser
from 
(
				select 
				DATEPART(mm,membership_creationDate) Quarter,
					CASE WHEN (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) >= 16 
									and (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) < 23 then 'U22'
							WHEN (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) >= 23 
									and (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) < 30 then 'U23-29'
							WHEN (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) >= 30 
									and (@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))) < 100 then 'U30+'
							ELSE 'Unknown' END AS Age,
					count(distinct membership_id) numbUser
					
				from cognetic_data_transaction a 
				join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
				left join cognetic_campaigns_complex e on a.transaction_complexid = e.complex_id
				join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
				INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
				LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id and transaction_cardNumber = card_cardNumber
				LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
				INNER JOIN cognetic_members_club ON membership_clubid = club_id
				WHERE ISNULL(membership_deleted,0) = 0 
					and transaction_complexid = 5
					and membership_creationDate >= @fromdate
					and membership_creationDate < @todate
					and transaction_time >= @fromdate
					and transaction_time < @todate
				group by 	(@year - CONCAT(REPLACE(person_centuryOfBirth,'??','20'), REPLACE(person_yearOfBirth,'??','20'))),DATEPART(mm,membership_creationDate)
) A 
WHERE A.Age <> 'Unknown'
group by A.Quarter, A.Age 
order by A.Quarter, A.Age 
