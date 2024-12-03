--query lay data synergy GEE
select
CONVERT(NVARCHAR(32),HashBytes('MD5', person_mobilePhone),2) as phone,
--CONVERT(NVARCHAR(34), sys.fn_varbintohexstr(HashBytes('MD5', person_mobilePhone)), 2)  as phone_type2,
CONVERT(NVARCHAR(32),HashBytes('MD5', person_email),2) as email,
--CONVERT(NVARCHAR(34), sys.fn_varbintohexstr(HashBytes('MD5', person_email)), 2) email_type2,
case when b.transactionItem_movieid is not null then b.transactionItem_movieid else c.item_id end as product_id,
case when b.transactionItem_movieid is not null then dz.movie_name else c.item_name end as product_name,
a.transaction_time as paid_at
from cognetic_data_transaction a 
join cognetic_data_transactionItem b on a.transaction_id = b.transactionItem_transactionid
left join cognetic_data_item c on b.transactionItem_itemid = c.item_id
left join cognetic_rules_movie dz on b.transactionItem_movieid = dz.movie_id
join cognetic_members_membership d on a.transaction_membershipid = d.membership_id
INNER JOIN (SELECT * FROM cognetic_core_person WHERE ISNULL(person_deleted,0) <> 1) cognetic_core_person ON membership_personid = person_id
LEFT OUTER JOIN	(SELECT card_code, card_cardNumber, card_membershipid, card_issuedComplexId FROM cognetic_members_card WHERE card_status IN (SELECT memberStatus_id FROM cognetic_setup_memberStatus WHERE memberStatus_isValidStatus = '1')) cognetic_members_card ON card_membershipid = membership_id and transaction_cardNumber = card_cardNumber
LEFT OUTER JOIN cognetic_rules_group ON group_id = person_staticGroupid
INNER JOIN cognetic_members_club ON membership_clubid = club_id
WHERE ISNULL(membership_deleted,0) = 0 
and cast(transaction_time as date) >= '2023-06-01'
and cast(transaction_time as date) < '2024-01-01'

