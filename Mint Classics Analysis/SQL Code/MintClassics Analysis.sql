-- In this project I will analyse the Mint Classics database in MySQL, with a goal of reducing or reorganising the inventory, and giving a report on the general performance of the company for more efficient business processes.

-- ----------------- -------------------------------------------------Business Understanding------------------------------------------------ ------------------------- --
-- Mint classics is a car model company looking to enhance its performance by optimization of its storage facilities. 
-- In the following analysis, my main goal is to understand the state of the company's inventory, and make suggestions to optimise its uses.

-- ----------------- ---------------------------------------------------Data Understanding-------------------------------------------------- ------------------------- --

USE mintclassics;

-- The distribution of products per warehouse:

SELECT 
	warehouseName,
    SUM(quantityInStock) AS storedProducts,
    warehousePctCap
FROM 
	products p
JOIN 
	wareHouses wh ON wh.warehouseCode = p.warehouseCode
GROUP BY 
	wh.warehouseCode;


-- Product kinds per warehouse:

SELECT 
    wh.warehouseName,
    p.productLine,
    SUM(p.quantityInStock) AS quantityAvailable,
    (SUM(p.quantityInStock) * 100.0 / total.totalQuantityInStock) AS percentage
FROM 
    products p
JOIN 
    warehouses wh ON wh.warehouseCode = p.warehouseCode
JOIN 
    (SELECT 
        warehouseCode, 
        SUM(quantityInStock) AS totalQuantityInStock
     FROM 
        products
     GROUP BY 
        warehouseCode) AS total 
        ON total.warehouseCode = wh.warehouseCode
GROUP BY 
    wh.warehouseName,
    p.productLine,
    total.totalQuantityInStock
ORDER BY 
    quantityAvailable DESC;


-- Total stock for every product

SELECT 
	productCode, 
    productName, 
    quantityInStock
FROM
	products
ORDER BY
	quantityInStock DESC;



-- Now, we analyse the sales of each product line:

SELECT 
    p.productLine,
    SUM(od.quantityOrdered) AS quantityOrdered,
    pl.storedProduct,
    ROUND(SUM(od.quantityOrdered)/pl.storedProduct*100, 1) AS pctSales,
    SUM(od.quantityOrdered*od.priceEach) AS Revenue
FROM
    orderdetails od
JOIN
    products p ON p.productCode = od.productCode
JOIN 
    (SELECT productLine, SUM(quantityInStock) AS storedProduct
     FROM products
     GROUP BY productLine) pl ON p.productLine = pl.productLine
GROUP BY 
    p.productLine;


-- And, the total revenue produced from each warehouse:

SELECT 
    wh.warehouseName,
    SUM(od.quantityOrdered) AS quantityOrdered,
    whs.storedProducts,
    ROUND(SUM(od.quantityOrdered)/whs.storedProducts*100, 1) AS pctSales,
    SUM(od.quantityOrdered*od.priceEach) AS Revenue
FROM
    orderdetails od
JOIN
    products p ON p.productCode = od.productCode
JOIN 
    warehouses wh ON p.warehouseCode = wh.warehouseCode
JOIN 
    (SELECT warehouseCode, SUM(quantityInStock) AS storedProducts
     FROM products
     GROUP BY warehouseCode) whs ON wh.warehouseCode = whs.warehouseCode
GROUP BY 
    p.warehouseCode
ORDER BY
    Revenue DESC;
    

-- Revenue from each product

SELECT 
    p.productCode,
    SUM(od.quantityOrdered) AS quantityOrdered,
    p.quantityInStock,
    ROUND(SUM(od.quantityOrdered)/p.quantityInStock*100, 1) AS pctSales,
    SUM(od.quantityOrdered*od.priceEach) AS Revenue
FROM
    orderdetails od
JOIN
    products p ON p.productCode = od.productCode
GROUP BY 
    p.productCode
ORDER BY pctSales, Revenue DESC;
