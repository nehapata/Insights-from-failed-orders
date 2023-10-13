
-- data_orders

select *
from data_orders

 -- 8 columns with 10,716 rows before cleaning and manipulation

---------------------------------------------------------------------------------------------------------------------------------------------------

-- checking duplicates

select count(order_gk), order_gk
from data_orders
group by order_gk
having count(order_gk) >1 

-- No duplicate orders found

---------------------------------------------------------------------------------------------------------------------------------------------------

-- checking if multiple keys(other than 4,9,0 and 1) exist for order_status and is_driver_assigned

select order_status_key, count(distinct(order_status_key))
from data_orders
group by order_status_key

select is_driver_assigned_key, count(distinct(is_driver_assigned_key))
from data_orders
group by is_driver_assigned_key

-- no keys other than 4, 9, 1 and 0 exist.

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Null Values

select *
from data_orders
where m_order_eta is NULL

-- m_order_eta i.e. time before order arrival is not specified if driver is not assigned. Hence, there are total 7902 rows where m_order_eta is null. 

select *
from data_orders
where cancellations_time_in_seconds is NULL

/* cancellation_time_in_seconds is not specified when order is cancelled by system and driver is not assigned. There are total 3409 rows where 
cancellation_time_in_seconds is null. 

Looking at the nature of the null values, I am going to keep them as they are. */

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Adding columns

Alter Table data_orders
Add order_status nvarchar(50);

Update data_orders
set order_status = case order_status_key when 4 then 'Cancelled by client' when 9 then 'Cancelled by system' end
                   

Alter Table data_orders
Add is_driver_assigned nvarchar(50);

Update data_orders
set is_driver_assigned =  case is_driver_assigned_key when 0 then 'No' when 1 then 'Yes' end

-- now data_orders has 10 columns and 10,716 rows.

-----------------------------------------------------------------------------------------------------------------------------------------------

-- data_offers

select *
from data_offers

-- 2 columns with 334,363 rows before cleaning and manipulation

-----------------------------------------------------------------------------------------------------------------------------------------------

-- checking duplicates

select count(offer_id), offer_id
from data_offers
group by offer_id
having count(offer_id) >1 

-- No duplicate offers found

------------------------------------------------------------------------------------------------------------------------------------------------

-- Null Values

select *
from data_offers
where order_gk is null and offer_id is null

-- No null values found

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Unique orders from offers data

select count(distinct(order_gk))
from data_offers -- 97,967 unique orders

-- Unique orders from orders data

select count(distinct(order_gk))
from data_orders -- 10,716 unique orders


-- it seems that data_offers contain all orders regardless of their status: failed or not failed.

--------------------------------------------------------------------------------------------------------------------------------------------------

-- joining two datasets to find out more about offers

select *
from data_orders Left Join data_offers 
On data_orders.order_gk = data_offers.order_gk

-- 12 columns with 34,374 rows. 

select count(distinct(data_orders.order_gk))
from data_orders Left Join data_offers 
On data_orders.order_gk = data_offers.order_gk -- 10,716 unique orders

select count(distinct(data_offers.offer_id))
from data_orders Left Join data_offers 
On data_orders.order_gk = data_offers.order_gk -- 31,268 unique offers

-- It seems that some orders have got multiple offers.

select count(data_orders.order_gk), data_orders.order_gk
from data_orders Left Join data_offers 
On data_orders.order_gk = data_offers.order_gk
group by data_orders.order_gk

-- The result of query showed that some orders did end up getting multiple offers.

-- checking what kind of orders got multiple offers

select d.order_datetime, d.origin_longitude, d.origin_latitude, d.m_order_eta, d.order_gk,
       count(d.order_gk) as total_offers, d.cancellations_time_in_seconds, d.order_status, d.is_driver_assigned
from data_orders d Left Join data_offers f
On d.order_gk = f.order_gk
group by d.order_gk, d.order_datetime, d.origin_longitude, d.origin_latitude, d.m_order_eta, d.order_gk,
        d.cancellations_time_in_seconds, d.order_status, d.is_driver_assigned
having count(d.order_gk) > 1 --count(d.order_gk) = 1

-- I found no specific differences between orders with multiple offers and orders with just one offer. 

/* 
   Since the table data_offers is not providing any additional information that can be used to solve the current problem, 
   I will use only data_orders table for further analysis.
*/

------------------------------------------------------------------------------------------------------------------------------------------------------

/*  I am going to save result of below query (with headers) as csv file  to my computer to transfer it to Tableau for visualization. */

select*
from data_orders -- data_orders is cleaned and updated
order by order_datetime