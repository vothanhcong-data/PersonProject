-- Show sale data top 5 table 

Select top 5*
From Return_Rate 


-- Looking at number of order 
    SELECT 
        Sum(Quantity) as Total_Order
    From Return_Rate 
   
-- Looking at number of return 
    Select
        Sum(Num_of_Return) as Total_return
    From (  
        Select Case When Returned = 'Yes' Then 1 Else 0 END as Num_of_Return
        From EU_Store
    ) as Return_group
-- --Join with EU_Store
Select R.Order_Date, R.Product_Name, R.Sales, R.Quantity, R.Discount, R.Profit, E.Returned
From Return_Rate as R
Left Join Eu_store as E
on R.Order_ID = E.Order_ID 

-- Calculate return_rate by Product 
With Return_Rate_Table as (
    SELECT Sale.Product_Name, sale.Num_of_Order, 
            Case When retrn.Num_of_Return is Null Then 0 Else retrn.Num_of_Return END as Num_of_Return -- Replace Value 'Null' = 0
    From (
            SELECT Order_ID, Product_Name,
                Sum(Quantity) as Num_of_Order
            From Return_Rate 
            Group by Product_Name,Order_ID) as Sale 
    Left Join (
            Select Order_ID,    
                Sum(Return1) as Num_of_Return
            From    
                (Select Order_ID, 
                    Case When Returned = 'Yes' Then 1 Else 0 END as Return1 -- Replace Value 'Yes' = 1
                From Eu_store ) as R
            Group by Order_ID
    ) as retrn 
    on Sale.Order_ID = retrn.Order_ID) 
SELECT Product_Name, Num_of_Order, Num_of_Return,
    Round((Num_of_Return/Num_of_Order)*100,2) as rate -- Calculate Return_Rate
From Return_Rate_Table

-- Create Table

Create Table Return_Rate_Table (
    Product_Name numeric,
    Num_of_Order numeric,
    Num_of_Return numeric
)
Insert Into Return_Rate_Table
    SELECT Sale.Product_Name, Sale.Num_of_Order, 
            CASE WHEN retrn.Num_of_Return IS NULL THEN 0 ELSE retrn.Num_of_Return END AS Num_of_Return
    FROM (
            SELECT Order_ID, Product_Name,
                SUM(Quantity) AS Num_of_Order
            FROM Return_Rate 
            GROUP BY Product_Name, Order_ID
    ) AS Sale 
    LEFT JOIN (
            SELECT Order_ID,    
                SUM(Return1) AS Num_of_Return
            FROM (
                SELECT Order_ID, 
                    CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END AS Return1 
                FROM Eu_store
            ) AS R
            GROUP BY Order_ID
    ) AS retrn 
    ON Sale.Order_ID = retrn.Order_ID
Select * From Return_Rate_Table
