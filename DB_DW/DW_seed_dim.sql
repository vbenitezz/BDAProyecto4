USE DB_DW;
GO

-- Insertar fechas desde 2020 hasta 2026
DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate DATE = '2026-12-31';

WITH DateRange AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateRange
    WHERE DateValue < @EndDate
)
INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfMonth, DayOfWeek, DayName, WeekOfYear, IsWeekend)
SELECT 
    -- DateKey en formato YYYYMMDD
    YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue) AS DateKey,
    DateValue AS FullDate,
    YEAR(DateValue) AS Year,
    DATEPART(QUARTER, DateValue) AS Quarter,
    MONTH(DateValue) AS Month,
    DATENAME(MONTH, DateValue) AS MonthName,
    DAY(DateValue) AS DayOfMonth,
    DATEPART(WEEKDAY, DateValue) AS DayOfWeek,
    DATENAME(WEEKDAY, DateValue) AS DayName,
    DATEPART(WEEK, DateValue) AS WeekOfYear,
    CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM DateRange
OPTION (MAXRECURSION 0);
GO

-- Verificar resultado
SELECT TOP 10 * FROM DimDate ORDER BY DateKey;

USE DB_DW;
GO

INSERT INTO DimCustomer (CustomerID, CustomerName, Email, City, Region, Segment, IsActive, ValidFrom, ValidTo, IsCurrent)
SELECT 
    CustomerID,
    FullName AS CustomerName,
    Email,
    ISNULL(City, 'No especificada') AS City,
    ISNULL(StateProvince, 'No especificada') AS Region,
    CustomerSegment AS Segment,   -- CORPORATIVO, PREMIUM, REGULAR
    1 AS IsActive,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM DB_STAGING.dbo.stg_Customers;
GO

-- Verificar
SELECT COUNT(*) AS TotalClientes FROM DimCustomer;
SELECT TOP 5 CustomerID, CustomerName, Segment, City, Region FROM DimCustomer;

-- Verificar
SELECT COUNT(*) AS TotalClientes FROM DimCustomer;
SELECT TOP 5 * FROM DimCustomer;

INSERT INTO DimProduct (ProductID, ProductName, CategoryID, CategoryName, SupplierID, SupplierName, UnitPrice, IsActive)
SELECT 
    p.ProductID,
    p.ProductName,
    p.CategoryID,
    c.CategoryName,
    p.SupplierID,
    s.SupplierName,
    p.SalePrice AS UnitPrice,   
    1 AS IsActive
FROM DB_STAGING.dbo.stg_Products p
LEFT JOIN DB_STAGING.dbo.stg_Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN DB_STAGING.dbo.stg_Suppliers s ON p.SupplierID = s.SupplierID;
GO

-- Verificar
SELECT COUNT(*) AS TotalProductos FROM DimProduct;
SELECT TOP 5 ProductID, ProductName, CategoryName, SupplierName, UnitPrice FROM DimProduct;


INSERT INTO DimStore (StoreID, StoreName, StoreAddress, City, Region, StoreType, IsActive)
SELECT 
    StoreID,
    StoreName,
    Address AS StoreAddress,
    City,
    Region,
    'Sucursal' AS StoreType,  
    ISNULL(IsActive, 1) AS IsActive
FROM DB_STAGING.dbo.stg_Stores;
GO

SELECT COUNT(*) AS TotalTiendas FROM DimStore;


INSERT INTO DimSalesperson (SalespersonID, FullName, Email, StoreID, HireDate, IsActive)
SELECT 
    SalespersonID,
    FullName,
    Email,
    StoreID,
    HireDate,
    ISNULL(IsActive, 1) AS IsActive
FROM DB_STAGING.dbo.stg_Salespersons;
GO

SELECT COUNT(*) AS TotalVendedores FROM DimSalesperson;


INSERT INTO DimSupplier (SupplierID, SupplierName, ContactName, City, Region, IsActive)
SELECT 
    SupplierID,
    SupplierName,
    NULL AS ContactName,  
    City,
    StateProvince AS Region,
    ISNULL(IsActive, 1) AS IsActive
FROM DB_STAGING.dbo.stg_Suppliers;
GO

SELECT COUNT(*) AS TotalProveedores FROM DimSupplier;

INSERT INTO DimCategory (CategoryID, CategoryName, ParentCategory)
SELECT 
    CategoryID,
    CategoryName,
    NULL AS ParentCategory  -- No hay jerarquía definida
FROM DB_STAGING.dbo.stg_Categories;
GO

SELECT COUNT(*) AS TotalCategorias FROM DimCategory;

INSERT INTO DimCampaign (CampaignID, CampaignName, StartDate, EndDate, DiscountPercent)
SELECT 
    CampaignID,
    CampaignName,
    StartDate,
    EndDate,
    DiscountPercentage AS DiscountPercent
FROM DB_STAGING.dbo.stg_Campaigns;
GO

SELECT COUNT(*) AS TotalCampañas FROM DimCampaign;

INSERT INTO DimSalesChannel (ChannelID, ChannelName, ChannelType)
SELECT 
    SalesChannelID AS ChannelID,
    ChannelName,
    CASE 
        WHEN ChannelName = 'Online' THEN 'Digital'
        WHEN ChannelName = 'App' THEN 'Digital'
        ELSE 'Físico'
    END AS ChannelType
FROM DB_STAGING.dbo.stg_SalesChannels;
GO

SELECT COUNT(*) AS TotalCanales FROM DimSalesChannel;


SELECT 'DimDate' AS Dimension, COUNT(*) AS Registros FROM DimDate
UNION ALL
SELECT 'DimCustomer', COUNT(*) FROM DimCustomer
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL
SELECT 'DimStore', COUNT(*) FROM DimStore
UNION ALL
SELECT 'DimSalesperson', COUNT(*) FROM DimSalesperson
UNION ALL
SELECT 'DimSupplier', COUNT(*) FROM DimSupplier
UNION ALL
SELECT 'DimCategory', COUNT(*) FROM DimCategory
UNION ALL
SELECT 'DimCampaign', COUNT(*) FROM DimCampaign
UNION ALL
SELECT 'DimSalesChannel', COUNT(*) FROM DimSalesChannel;