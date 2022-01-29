use retail_segmentation;
select * from txn;

# Step 1: Get the transaction table at unique customer level.

create table tx_instore as
select * from txn where Home_Shopping_Flg = 0; 

create table tx_online
select *  from txn where Home_Shopping_Flg = 1;

# Step 2: Join the above table with Customer table. 

create table cv as 
select c.*,coalesce(i.visits,0) as VisitsStore, coalesce(i.tot_spend,0) as Storespend,coalesce(i.tot_qty,0) as Storeqty,coalesce(o.visits,0) as OnlineVisits,coalesce(o.tot_spend,0) as Onlinespend,coalesce(o.tot_qty,0) as OnlineQty from cust c
left join tx_instore i on c.household_id = i.household_id  
left join tx_online o on c.household_id = o.household_id;

create table cv1 as
select *, (case when VisitsStore > 0 and OnlineVisits = 0 then 'InstoreOnly' 
				when VisitsStore = 0 and OnlineVisits > 0 then 'OnlineOnly'
                when VisitsStore > 0 and OnlineVisits > 0 then 'Multichannel'
                when VisitsStore = 0 and OnlineVisits = 0 then 'NoShopping'
                end) as ShoppingMode from cv;
                
                
# Step 3: Profile Customers Segments basis shopping mode.
# Use the following variables for profiling - visits, spend, quantity, loyalty, preferred store format, lifestyle, gender

select ShoppingMode, round(avg(VisitsStore)) as avg_visit_instore, 
					round(avg(OnlineVisits)) as avg_visit_online, 
					round(avg(Storespend)) as avg_spend_instore, 
                    round(avg(Onlinespend)) as avg_spend_online
from cv1 group by ShoppingMode;

# Shopping Model Segment Vs Loyalty Segments


select ShoppingMode, 
concat(cast(round(100*sum(case when loyalty = "Very Frequent Shoppers" then 1 else 0 end)/count(loyalty),0)as char),"%") as VeryFrequentShopper,
concat(cast(round(100*sum(case when loyalty = "Occasional Shoppers" then 1 else 0 end)/count(loyalty),0) as char), "%") as OccasionalShoppers,
concat(cast(round(100*sum(case when loyalty = "No Longer Shopping" then 1 else 0 end)/count(loyalty),0) as char), "%") as NoLongerShopping,
concat(cast(round(100*sum(case when loyalty = "Lapsing Shoppers" then 1 else 0 end)/count(loyalty),0) as char), "%") as LapsingShoppers
					 from cv1 group by ShoppingMode;
# Key Insight - Almost 80% of Multichannel shoppers are Very Freq shoppers. For instore only there are 40% (2000 + customers) who are occasional shoopers
# Recommendation - The company should build strategy to migrate instore only occasional customers to online shopping. That ways even if we are able to migrate 10% of 2000+ customers
# we will get an additional 200 customers in multichannel. Thereby growing the multichannel by 50%.

# Shopping Model Segment Vs Preferred store Segments  
                   
select ShoppingMode,
concat(cast(round(100*sum(case when preferred_store_format = "Very Large Stores" then 1 else 0 end)/count(preferred_store_format),0) as char), "%") as VeryLargeStores,
concat(cast(round(100*sum(case when preferred_store_format = "Large Stores" then 1 else 0 end)/count(preferred_store_format),0) as char), "%") as LargeStores,
concat(cast(round(100*sum(case when preferred_store_format = "Others" then 1 else 0 end)/count(preferred_store_format),0) as char), "%") as 'Others',
concat(cast(round(100*sum(case when preferred_store_format = "Small Stores" then 1 else 0 end)/count(preferred_store_format),0) as char), "%") as SmallStores,
concat(cast(round(100*sum(case when preferred_store_format = "Mom and Pop Stores" then 1 else 0 end)/count(preferred_store_format),0) as char), "%") as MomandPopStores
					 from cv1 group by ShoppingMode;


# Shopping Model Segment Vs Lifestyle Segments
select ShoppingMode, 
concat(cast(round(100*sum(case when lifestyle = "Middle Class" then 1 else 0 end)/count(lifestyle),0) as char), "%") as MiddleClass,
concat(cast(round(100*sum(case when lifestyle = "Low Affluent Customers" then 1 else 0 end)/count(lifestyle),0) as char), "%") as LowAffluentCustomers,
concat(cast(round(100*sum(case when lifestyle = "Very Affluent Customers" then 1 else 0 end)/count(lifestyle),0) as char), "%") as VeryAffluentCustomers
					 from cv1 group by ShoppingMode;
                     
# Shopping Model Segment Vs Gender
select ShoppingMode, 
concat(cast(round(100*sum(case when gender = "M" then 1 else 0 end)/count(gender),0) as char), "%") as Male,
concat(cast(round(100*sum(case when gender = "F" then 1 else 0 end)/count(gender),0) as char),"%") as Female,
concat(cast(round(100*sum(case when gender = "X" then 1 else 0 end)/count(gender),0) as char), "%") as X
					 from cv1 group by ShoppingMode;
                     
select * from cv1;
# Step 4 - Value Based Segmentation 
create table cv2 as
select *, (VisitsStore + OnlineVisits) as visit_total, round((Storespend + Onlinespend),2) as spend_total from cv1;

create table cv3 as
select *, ceil(3*rank() over(order by visit_total asc)/6000) as  visit_score,
		  ceil(3*rank() over(order by spend_total asc)/6000) as  spend_score from cv2;

create table cv4 as
select *, (visit_score + spend_score) as total_score from cv3;

create table cv5 as
select *, ceil(3*rank() over(order by total_score asc)/6000) as  final_score from cv4;


create table cv6 as
select *, (case when final_score = 1 then 'Laggard' 
				when final_score = 2 then 'Potential' 
                when final_score = 3 then 'Champion' end) as ValueSegments from cv5;

 
# Step 5: Profile for Value Segments
# Shopping Model Segment Vs Loyalty Segments

select ValueSegments,
concat(cast(round(100*sum(case when loyalty = "Very Frequent Shoppers" then 1 else 0 end)/count(loyalty),0) as char), "%") as VeryFrequentShopper,
concat(cast(round(100*sum(case when loyalty = "Occasional Shoppers" then 1 else 0 end)/count(loyalty),0) as char), "%") as OccasionalShoppers,
concat(cast(round(100*sum(case when loyalty = "No Longer Shopping" then 1 else 0 end)/count(loyalty),0) as char), "%") as NoLongerShopping,
concat(cast(round(100*sum(case when loyalty = "Lapsing Shoppers" then 1 else 0 end)/count(loyalty),0) as char), "%") as LapsingShoppers
from cv6 group by ValueSegments;

# Shopping Value Segments Vs Lifestyle Segments vs Preferred_Store_Format
select ValueSegments, count(1) as Count_Shoppers,
					concat(cast(round(100*sum(case when preferred_store_format = 'Very Large Stores' then 1 else 0 end)/count(1)) as char),"%")  as VeryLargeStores,
					concat(cast(round(100*sum(case when preferred_store_format = 'Large Stores' then 1 else 0 end)/count(1)) as char), "%") as LargeStores,
                    concat(cast(round(100*sum(case when preferred_store_format = 'Small Stores' then 1 else 0 end)/count(1)) as char), "%") as SmallStores,
                    concat(cast(round(100*sum(case when preferred_store_format = 'Mom and Pop Stores' then 1 else 0 end)/count(1)) as char), "%") as MomPopStores,
                    concat(cast(round(100*sum(case when preferred_store_format = 'Others' then 1 else 0 end)/count(1)) as char), "%") as 'Others'
from cv6 group by ValueSegments;

# Shopping Value Segments Vs Lifestyle Segments
select ValueSegments,
concat(cast(round(100*sum(case when lifestyle = "Middle Class" then 1 else 0 end)/count(lifestyle),0) as char), "%") as MiddleClass,
concat(cast(round(100*sum(case when lifestyle = "Low Affluent Customers" then 1 else 0 end)/count(lifestyle),0) as char), "%") as LowAffluentCustomers,
concat(cast(round(100*sum(case when lifestyle = "Very Affluent Customers" then 1 else 0 end)/count(lifestyle),0) as char), "%") as VeryAffluentCustomers
from cv6 group by ValueSegments;
                     
# Shopping Value Segments Vs Gender
select ValueSegments, 
concat(cast(round(100*sum(case when gender = "M" then 1 else 0 end)/count(gender),0) as char), "%") as Male,
concat(cast(round(100*sum(case when gender = "F" then 1 else 0 end)/count(gender),0) as char), "%") as Female,
concat(cast(round(100*sum(case when gender = "X" then 1 else 0 end)/count(gender),0) as char), "%") as X
from cv6 group by ValueSegments;
