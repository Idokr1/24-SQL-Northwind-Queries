use Northwind

-- 1 -- Show the first name, last name and telephone number for all the employees, except those who live in UK.
select FirstName, LastName, HomePhone, Country
from Employees
where Country <> 'UK'

-- 2 -- Show all product details for products whose unit price is greater than $10 and quantity in stock greater than 2. Sort by product price.
select *
from Products
where UnitPrice > 10 and UnitsInStock > 2
order by UnitPrice

-- 3 -- Show the first name, last name and telephone number for the employees who started working in the company in 1992-1993.
select FirstName, LastName, HomePhone, ltrim(HireDate)
from Employees
where year(HireDate) between 1992 and 1993

-- 4 -- Show the product name, Company name of the supplier and stock quantity of the products that have 15 or more items in stock and the Product name starts with B or C or M.
select ProductName, CompanyName, UnitsInStock
from Products, Suppliers
where Products.SupplierID = Suppliers.SupplierID and UnitsInStock > 15 and (ProductName like 'b%' or ProductName like 'c%' or ProductName like 'm%')

-- 5 -- Show all details for products whose Category Name is ' Meat/Poultry ' Or 'Dairy Products '. Sort them by product name.
select ProductID, ProductName, SupplierID, p.CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued, CategoryName
from Products p, Categories c
where P.CategoryID = C.CategoryID and (CategoryName like 'meat/poultry' or CategoryName like 'Dairy Products')
order by ProductName

-- 6 -- Show Category name, Product name and profit for each product (how much money the company will earn if they sell all the units in stock). Sort by the profit.
select CategoryName, ProductName, UnitPrice * UnitsInStock 'ProfitPerProduct'
from Products P, Categories C
where P.CategoryID = C.CategoryID
order by ProfitPerProduct

-- 7 -- Show the Employees' first name, last name and Category Name of the products which they have sold (show each category once).
select distinct FirstName, LastName, CategoryName
from Employees E, Orders O, [Order Details] OD, Products P, Categories C
where E.EmployeeID = O.EmployeeID and
O.OrderID = OD.OrderID and
OD.ProductID = P.ProductID and
P.CategoryID = C.CategoryID
order by FirstName

-- 8 -- Show the first name, last name, telephone number and date of birth for the employees who are aged older than 35. Order them by last name in descending order.
select FirstName, LastName, HomePhone, BirthDate
from Employees
where year(getdate()) - year(BirthDate) > 35
order by LastName desc


-- 9 -- Show each employee?s name, the product name for the products that he has sold and quantity that he has sold.
select FirstName, LastName, ProductName, Quantity
from Employees E, Orders O, [Order Details] OD, Products P
where E.EmployeeID = O.EmployeeID and
O.OrderID = OD.OrderID and
OD.ProductID = P.ProductID

-- 10 -- Show for each order item ? the customer name and order id, product name, ordered quantity, product price and total price (Ordered quantity * product price) and gap between ordered date and shipped date (the gap in days). Order by order id.
select ContactName, O.OrderID, ProductName, Quantity 'Ordered Quantity', OD.UnitPrice 'Product Price', Quantity * OD.UnitPrice 'Total Price', day(ShippedDate) - day(OrderDate) 'Gap In Days'
from Customers C, Orders O, [Order Details] OD, Products P
where C.CustomerID = O.CustomerID and
O.OrderID = OD.OrderID and
OD.ProductID = P.ProductID
order by O.OrderID

-- 11 -- How much each customer paid for all the orders he had committed together?
select ContactName, sum(UnitPrice * Quantity) 'Total Sold'
from Customers C, Orders O, [Order Details] OD
where C.CustomerID = O.CustomerID and
O.OrderID = OD.OrderID
group by ContactName

-- 12 -- In which order numbers was the ordered quantity greater than 10% of the quantity in stock?
select OD.OrderID, UnitsInStock, Quantity 'Ordered Quantity'
from [Order Details] OD, Products P
where OD.ProductID = P.ProductID and
OD.Quantity > P.UnitsInStock * 0.1

-- 13 -- Show how many Employees live in each country and their average age.
select Country, avg(Year(GetDate()) - Year(BirthDate)) 'Average Age', count(Country) 'Amount of Employees in Each Country'
from Employees
group by Country

-- 14 -- What would be the discount for all the London customers (together), if after 5 days of gap between the order date and shipping date they get a 5% discount per item they bought?
select sum(Discount + 0.05) 'Discount'
from Customers C,[Order Details] OD,Orders O
where C.CustomerID = O.CustomerID and O.OrderID = OD.OrderID and city='London' and day(OrderDate-ShippedDate) > 5

-- 15 -- Show the product id, name, stock quantity, price and total value (product price * stock quantity) for products whose total bought quantity is greater than 500 items.
select P.ProductID, ProductName, P.UnitsInStock, P.UnitPrice, (P.UnitsInStock * P.UnitPrice) 'Total Value', sum(OD.Quantity) 'Total Quantity'
from Products P, [Order Details] OD
where P.ProductID = OD.ProductID
group by P.ProductID, ProductName, P.UnitsInStock, P.UnitPrice
having sum(OD.Quantity) > 500
order by ProductName

-- 16 -- For each employee display the total price paid on all of his orders that hasn?t shipped yet.
select E.EmployeeID, E.FirstName, round(sum((OD.Quantity * OD.UnitPrice)*(1-Discount)),2) 'Total Price Paid'
from Employees E, Orders O, [Order Details] OD
where E.EmployeeID = O.EmployeeID and OD.OrderID = O.OrderID and ShippedDate is null
group by E.EmployeeID, E.FirstName

-- 17 -- For each category display the total sales revenue, every year.
select year(OrderDate)'Year', C.CategoryID, CategoryName, round(sum((OD.Quantity * OD.UnitPrice)*(1-Discount)),2) 'Total Sales Revenue'
from Categories C, Products P, [Order Details] OD, Orders O
where C.CategoryID = P.CategoryID and P.ProductID = OD.ProductID and OD.OrderID = O.OrderID
group by year(OrderDate), C.CategoryID, CategoryName
order by C.CategoryID

-- 18 -- Which Product is the most popular? (number of items)
select top 1  P.ProductName, sum(OD.Quantity) 'numberOfItems'
from Products P,[Order Details] OD
where P.ProductID = OD.ProductID
group by P.ProductName
order by numberOfItems desc

-- 19 -- Which Product is the most profitable? (income)
select top 1 ProductName, round(sum(OD.Quantity * OD.UnitPrice* (1-Discount)),2) 'Income'
from Products P,[Order Details] OD
where P.ProductID = OD.ProductID
group by ProductName
order by Income desc

-- 20 -- Display products that their price higher than the average price of their Category.
with Question20 as (select C.CategoryID, C.CategoryName, avg(OD.UnitPrice) 'averagePrice'
			    from [Order Details] OD, Categories C,Products P
			    where C.CategoryID = P.CategoryID 
				and  P.ProductID = OD.ProductID 
				group by C.CategoryID, C.CategoryName)
select P.ProductID, ProductName, UnitPrice, averagePrice, P.CategoryID, CategoryName
from Question20 join Products P on Question20.CategoryID = p.CategoryID
where P.UnitPrice > averagePrice
order by P.ProductID

-- 21 -- For each city (in which our customers live), display the yearly income average.
select distinct C.City, year(O.OrderDate) '_year_', round(avg((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)),2) 'Income Average'
from Customers C,[Order Details] OD,orders O
where C.CustomerID = o.CustomerID and O.OrderID = OD.OrderID
group by C.City,year(o.OrderDate)
order by City

-- 22 -- For each month display the average sales in the same month all over the years.
select month(O.OrderDate) '_Month_', round(avg(UnitPrice * Quantity * (1- Discount)),2) 'Average Sales'
from [Order Details] OD, Orders O
where OD.OrderID = O.OrderID
group by month(O.OrderDate)
order by _Month_

-- 23 -- Display a list of products and OrderID of the largest order ever placed for each product.
with Question23 as (select P.ProductName, max(OD.Quantity) as largestOrder
					from [Order Details] OD ,Products P
					where p.ProductID = od.ProductID
					group by p.ProductName)
select distinct P.ProductName, OD.OrderID, largestOrder
from Products P, [Order Details] OD, Question23
where P.ProductID = OD.ProductID
and OD.Quantity >= Question23.largestOrder
and P.ProductName = Question23.ProductName
group by P.ProductName, largestOrder, OD.OrderID
order by p.ProductName

-- 24 -- Display for each year, the customer who purchased the highest amount.
with HighestAmountPerYear as 
	(select year(OrderDate) 'OrderYear', C.CustomerID, sum(Quantity * UnitPrice * (1 - Discount)) 'TotalPrice'
	 from Customers C join Orders O
	 on C.CustomerID = O.CustomerID
	 join [Order Details] OD on O.OrderID = OD.OrderID
	 group by year(OrderDate), C.CustomerID)
select distinct HA.orderYear, round(max(HA.TotalPrice),2) 'MaxTotalPrice', C.ContactName, C.CustomerID
from Customers C Join HighestAmountPerYear HA 
on c.CustomerID = HA.CustomerID
group by HA.orderYear, C.ContactName, c.CustomerID
	having max(HA.TotalPrice) in (select max(TotalPrice) from HighestAmountPerYear group by orderYear)
order by orderYear

