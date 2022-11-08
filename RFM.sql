-- RFM Analyze

Select * 
from Project1.dbo.[Online Retail Data]
;
-- CLEAN THE DATA

-- Remove dupicate row
Drop table if exists Project1.dbo.[Online Retail Data_1]
Select distinct * 
into Project1.dbo.[Online Retail Data_1]
from Project1.dbo.[Online Retail Data]
;

-- Add Identiy column
Alter table Project1.dbo.[Online Retail Data_1] 
	Add ID int Identity(1,1)
;
-- Check Column datatype
select * 
from information_schema.tables t
join information_schema.columns c on t.table_name = c.table_name
where t.table_name = 'Online Retail Data_1'
;
-- Price suppose to be Float/Numberic/Int... and InvoiceDate suppose to be Date/Datetime 
-- but it both in Varchar => Checking on the 2 columns

Select * 
from project1.dbo.[Online Retail Data_1] 
where len(InvoiceDate)<11 
;
-- =>The Description is slpitted and some part is loccated in other column
-- The common of these 'dirty' row is they all have the delimiter ',' in country, which clean row not have.

Select * 
from project1.dbo.[Online Retail Data_1] 
where country like '%,%'
;
-- => the Country value of these row contain other value like price,customerid,... and was split by delimiter ','
-- Split Country to column with delimiter ','
-- The Paresename syntax slpit by ',' and '.' so replace it with '*' and replace it back later
Select 
	*,
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 1)) AS [S1],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 2)) AS [S2],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 3)) AS [S3],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 4)) AS [S4]
from Project1.dbo.[Online Retail Data_1]
where country like '%,%'
Order by S1, S2, S3, S4
;
-- Put values in their suppose to be position.
With tbl as(
Select 
	*,
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 1)) AS [S1],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 2)) AS [S2],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 3)) AS [S3],
	REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(country,'.','*')), ',', '.'), 4)) AS [S4]
from Project1.dbo.[Online Retail Data_1]
where country like '%,%'
)
Select 
	ID,
	Invoice,
	StockCode,
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then CONCAT([Description],Quantity) 
		When S1 is not null and s3 is not null and s4 is null then CONCAT([Description],Quantity,InvoiceDate)
		When s1 is not null and s2 is not null and s3 is null then CONCAT([Description],Quantity) 
		Else CONCAT([Description],Quantity,InvoiceDate,Price)
	End as [Description],
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then InvoiceDate
		When S1 is not null and s3 is not null and s4 is null then Price
		When s1 is not null and s2 is not null and s3 is null then InvoiceDate
		Else [Customer ID]
	End as Quantity,
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then Price
		When S1 is not null and s3 is not null and s4 is null then [Customer ID]
		When s1 is not null and s2 is not null and s3 is null then Price
		Else S1
	End as InvoiceDate,
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then [Customer ID]
		When S1 is not null and s3 is not null and s4 is null then REPLACE(s1,'*','.') -- Replace back * to .
		When s1 is not null and s2 is not null and s3 is null then [Customer ID]
		Else REPLACE(s2,'*','.')
	End as Price,
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then null
		When S1 is not null and s3 is not null and s4 is null then S2
		When s1 is not null and s2 is not null and s3 is null then S1
		Else S3
	End as [Customer ID],
	Case
		when S1 is null and S2 is null and S3 is null and S4 is null then replace(country,',','')
		When S1 is not null and s3 is not null and s4 is null then S3
		When s1 is not null and s2 is not null and s3 is null then S2
		Else S4
	End as Country
Into ##A
From tbl
;
Select * from ##A
;
-- Update to cleaned row to table
Update Project1.dbo.[Online Retail Data_1]
Set Project1.dbo.[Online Retail Data_1].[Description] = b.[Description],
	Project1.dbo.[Online Retail Data_1].Quantity = b.Quantity,
	Project1.dbo.[Online Retail Data_1].InvoiceDate = b.InvoiceDate,
	Project1.dbo.[Online Retail Data_1].Price = b.Price,
	Project1.dbo.[Online Retail Data_1].[Customer ID] = b.[Customer ID],
	Project1.dbo.[Online Retail Data_1].country = b.Country
From Project1.dbo.[Online Retail Data_1] a
Inner join ##A as b
on a.ID = b.ID
;
Select * 
from Project1.dbo.[Online Retail Data_1]
;
-- Change data type of Quantity, invoiceDate, Price, Customer ID

Alter table Project1.dbo.[Online Retail Data_1]
Alter column 
	Quantity int
;
Alter table Project1.dbo.[Online Retail Data_1]
Alter column 
	InvoiceDate datetime
;
Alter table Project1.dbo.[Online Retail Data_1]
Alter column 
	Price numeric(10,2)
Alter table Project1.dbo.[Online Retail Data_1]
Alter column 
	[Customer ID] int
;
--Check on every column
Select Distinct	
	Invoice
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	StockCode
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	[Description]
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	Quantity
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	InvoiceDate
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	Price
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
[Customer ID]
from Project1.dbo.[Online Retail Data_1]
;
Select Distinct	
	Country
from Project1.dbo.[Online Retail Data_1]
-- => Some row Quantity < 0, CustomerID is null or =0 
--=> Check on them
Select * 
from Project1.dbo.[Online Retail Data_1] 
Where Quantity <=0
;
Select * 
from Project1.dbo.[Online Retail Data_1] 
where [Customer ID] = 0 or  [Customer ID] is null
;
-- There 3 case
--	1. Quantity <0 and there is no Customer ID => It's company's internal activity to manage the warehourse => remove
--	2. Quantity <0 and there is customer ID => Cusstomer returned there goods for some reasons => keep
--	3. Quantity >0 and there is no Customer ID => Missing Cus ID => remove

Delete from Project1.dbo.[Online Retail Data_1] 
where	[Customer ID] is null or [Customer ID] = 0
;

-- START RATING RFM

With tbl as(
Select
	Invoice,
	Invoicedate,
	[customer id],
	sum(Quantity*price) as Total
From Project1.dbo.[Online Retail Data_1]
Group by 
	Invoice,
	Invoicedate,
	[customer id]
),
 tbl2 as (Select
	Invoice,
	[Customer ID],
	Total,
	Case
		when total > 0 then Invoicedate
		end as [Purchase date] -- Query purchase date an skip return date
from tbl
)
,
tbl3 as(
Select 
	[Customer ID],
	sum(total) as Monetary,
	Max([purchase date]) as [Most recent purchase],
	Count(distinct(case when total >0 then invoice end)) as [purchase count],
	Count(distinct(case when total <0 then invoice end)) as [return count]
from tbl2
Group by [Customer ID]
)
Select 
	[Customer ID],
	Datediff(d, [Most recent purchase],'20111203') as Recency,
	[purchase count]-[return count] as Frequency,
	Monetary
into project1.dbo.[customer RFM]
from tbl3

-- For Customer which have Frequency <= 0 or Monetary <= 0 or Recency is null 
Select 
	[Customer ID],
	'Alert' as Classify
Into Project1.dbo.[Customer RFM Alert Class]
from project1.dbo.[customer RFM] 
where Recency is null
	or Frequency <=0
	or Monetary <= 0

-- For other customer, first caculate the range and average of Recency

Select 
	MIN(recency),
	Max(recency),
	AVG(Recency)
from project1.dbo.[customer RFM] 
where	Recency is not null
	and Frequency >0
	and Monetary > 0

--The range is 1-732 days, average is 193 days so split it to 5 range: 1-50 as 5, 51-150 as 4, 151 - 300 as 3, 300 - 500 as 2, other as 1 
-- For F and M, classify Rank 0-20% as 5, Over 20% to 40% as 4, over 40%-60% as 3, over 60% to 80% as 2, other as 1

-- Rating
with tbl4 as (
Select
	*,
	PERCENT_RANK() over (Order by Frequency DESC) as F_Rank,
	PERCENT_RANK() over (Order by Monetary DESC) as M_Rank
from project1.dbo.[customer RFM] 
where	Recency is not null
	and Frequency >0
	and Monetary > 0
)
,
tbl5 as (Select
	*,
	Case 
		When Recency <=50 then 5
		When Recency <=150 then 4
		when Recency <= 300 then 3
		when Recency <= 500 then 2
		Else 1
	End as R_rate,
	Case
		When F_Rank <= 0.2 then 5 
		When F_Rank <= 0.4 then 4
		When F_Rank <= 0.6 then 3
		When F_Rank <= 0.8 then 2
		Else 1
	End as F_rate,
	Case
		When M_Rank <= 0.2 then 5 
		When M_Rank <= 0.4 then 4
		When M_Rank <= 0.6 then 3
		When M_Rank <= 0.8 then 2
		Else 1
	End as M_rate
From tbl4
)
,
tbl6 as (
Select
	*,
	Concat(cast(F_rate as float)/2 + cast(M_Rate as float)/2,'-',R_rate) as Rating
From tbl5
)
Select 
	[Customer ID],
	Case 
		when Rating = '5-5' then 'Champion'
		when Rating in ('5-4','5-3','4-3','4-4','4-5','4.5-3','4.5-4','4.5-5') then 'Loyal Customer'
		when Rating in ('3-5','3-4','2-5','2-4','3.5-4','3.5-5','2.5-4','2.5-5') then 'Promising'
		When Rating in ('1-5','1.5-5') then 'New Customer'
		when Rating in ('1-4', '1.5-4') then 'Warm Leads'
		When Rating in ('1-3','1.5-3') then 'Cold Leads'
		When Rating in ('3-2', '3-3','2-2','2-3','3.5-3','2.5-2','2.5-3') then 'Need Attention'
		When Rating in ('5-1', '5-2', '4.5-1','4.5-2') then 'Shouldn''''t lose'
		When Rating in ('4-1','4-2','3-1','3.5-1','3.5-2','2.5-1') then 'Sleepers'
		When Rating in ('1-1','2-1','1-2','1.5-1','1.5-2') then 'Lost' 
	end as Classify
Into Project1.dbo.Customer_classify
from tbl6

Select * from Project1.dbo.Customer_classify

Insert into Project1.dbo.Customer_classify
Select * from Project1.dbo.[Customer RFM Alert Class]

Select * from Project1.dbo.Customer_classify