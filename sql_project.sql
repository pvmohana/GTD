SELECT * FROM mahendra.f_inventory_adjusted;

alter table f_inventory_adjusted
add column Sales
decimal(10,2) ;

select @@sql_safe_updates;

set sql_safe_updates = 0;
update  mahendra.f_inventory_adjusted
set Sales = quantityonhand * price;  

-- top performing products wise sales
select productgroup,
sum(sales) as total_sales
from f_inventory_adjusted
group by productgroup
order by total_sales desc
limit 5;            

-- inventory values
select productname,quantityonhand, costamount,
(costamount * quantityonhand) as Inventory_value
from f_inventory_adjusted;

select productname, inventory_value
from f_inventory_adjusted;

-- adding column inventory value
alter table f_inventory_adjusted
add column Inventory_Value
decimal(10,2) ;

select @@sql_safe_updates;

set sql_safe_updates = 0;

update f_inventory_adjusted
set Inventory_Value = costamount*quantityonhand ;  

-- Inventory status
select productname,productgroup,inventory_value,
case 
 when inventory_value <=5 then "Out Of Stock"
 when inventory_value >=20 then "In Stock"
 when inventory_value > 5 and inventory_value < 19 then "Under Stock"
 else "unknown"
 end as
 Invtory_Status
 from f_inventory_adjusted;
 
-- yoy sales% growth
select year(d.date) as year, sum(pd.sales) as total_sales,
lag(sum(pd.sales)) over(order by year(d.date)) as prev_yr_sales,
((sum(pd.sales) - lag(sum(pd.sales)) over(order by year(d.date))) /  lag(sum(pd.sales))
over(order by year(d.date))) * 100
as yoy_growth
from f_inventory_adjusted pd join f_sales d on 
pd.ProductKey = d.StoreKey
group by year;

-- statewise sales
select  storestate, sum(sales) as total_sales
from f_inventory_adjusted join d_store on f_inventory_adjusted.ProductKey = d_store.StoreKey
group by storestate
order by total_sales
limit 5;

-- top 5 store wise sales
select  storename, sum(sales) as total_sales
from f_inventory_adjusted join d_store on f_inventory_adjusted.ProductKey = d_store.StoreKey
group by storename
order by total_sales
limit 5;

-- region wise sales
select  storeregion, sum(sales) as total_sales
from f_inventory_adjusted join d_store on f_inventory_adjusted.ProductKey = d_store.StoreKey
group by storeregion;

-- purchase method wise sales
select  purchasemethod, sum(sales) as total_sales
from f_inventory_adjusted join f_sales on f_inventory_adjusted.ProductKey = f_sales.StoreKey
group by PurchaseMethod;

-- daily sales trend
select date(f_sales.date) as Sales_date, sum(f_inventory_adjusted.sales) as Total_sales,
lag(sum(f_inventory_adjusted.sales)) over(order by date(f_sales.date)) as prev_day_sales
from f_sales join f_inventory_adjusted on f_sales.StoreKey = f_inventory_adjusted.ProductKey
group by Sales_date; 

-- mtd qtd, ytd sales
select date(f_sales.date) as sales_date, f_inventory_adjusted.sales,
 sum(f_inventory_adjusted.sales) over(partition by year(f_sales.date) order by f_sales.date
 rows between unbounded preceding and current row) as ytd_sales,
 sum(f_inventory_adjusted.sales) over(partition by year(f_sales.date), month(f_sales.date) order by f_sales.date
 rows between unbounded preceding and current row) as Mtd_sales,
 sum(f_inventory_adjusted.sales) over(partition by year(f_sales.date), quarter(f_sales.date) order by f_sales.date
 rows between unbounded preceding and current row) as Qtd_sales
 from f_sales join f_inventory_adjusted on f_sales.storekey = f_inventory_adjusted.productkey;




 
           

 



  





