CREATE DATABASE DB_STAGING;
GO

USE DB_STAGING;
GO

CREATE TABLE stg_Categories (
    CategoryID INT,
    CategoryName VARCHAR(100),
    Description VARCHAR(255),
    IsActive BIT,
    CreatedDate DATETIME
);
GO

CREATE TABLE stg_Customers (
    CustomerID INT,
    FullName VARCHAR(150),
    DocumentNumber VARCHAR(20),
    Gender VARCHAR(20),
    BirthDate DATE,
    City VARCHAR(100),
    StateProvince VARCHAR(100),
    CustomerSegment VARCHAR(50),
    Email VARCHAR(150),
    Phone VARCHAR(20),
    RegistrationDate DATE,
    Age INT
);
GO

CREATE TABLE stg_Products (
    ProductID INT,
    CategoryID INT,
    SupplierID INT,
    ProductName VARCHAR(150),
    Brand VARCHAR(100),
    SKU VARCHAR(50),
    SalePrice DECIMAL(12,2),
    UnitCost DECIMAL(12,2),
    ProfitMargin DECIMAL(12,2),
    IsActive BIT
);
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    ProductName VARCHAR(150) NOT NULL,
    Brand VARCHAR(100),
    SKU VARCHAR(50) NOT NULL,
    SalePrice DECIMAL(12,2) NOT NULL,
    UnitCost DECIMAL(12,2) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

CREATE TABLE stg_Stores (
    StoreID INT,
    StoreName VARCHAR(150),
    City VARCHAR(100),
    Region VARCHAR(100),
    Address VARCHAR(200),
    Phone VARCHAR(20),
    OpeningDate DATE,
    IsActive BIT
);
GO

CREATE TABLE stg_Suppliers (
    SupplierID INT,
    SupplierName VARCHAR(150),
    TaxID VARCHAR(20),
    City VARCHAR(100),
    StateProvince VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(150),
    IsActive BIT
);
GO

CREATE TABLE stg_Sales (
    SaleID BIGINT,
    CustomerID INT,
    StoreID INT,
    SalespersonID INT,
    SalesChannelID INT,
    CampaignID INT,
    SaleDate DATETIME,
    PaymentMethod VARCHAR(50),
    TotalSaleAmount DECIMAL(14,2),
    SaleYear INT,
    SaleMonth INT
);
GO

CREATE TABLE stg_SalesDetails (
    SaleDetailID BIGINT,
    SaleID BIGINT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    UnitCost DECIMAL(12,2),
    DiscountAmount DECIMAL(12,2),
    TotalAmount DECIMAL(14,2),
    NetAmount DECIMAL(14,2)
);
GO

CREATE TABLE stg_DailyInventory (
    InventoryID BIGINT,
    ProductID INT,
    StoreID INT,
    InventoryDate DATE,
    InitialStock INT,
    StockIn INT,
    StockOut INT,
    FinalStock INT
);
GO

CREATE TABLE stg_SalesChannels (
    SalesChannelID INT,
    ChannelName VARCHAR(100)
);
GO

CREATE TABLE stg_Campaigns (
    CampaignID INT,
    CampaignName VARCHAR(150),
    StartDate DATE,
    EndDate DATE,
    DiscountPercentage DECIMAL(5,2),
    CampaignDurationDays INT
);
GO

CREATE TABLE stg_Salespersons (
    SalespersonID INT,
    StoreID INT,
    FullName VARCHAR(150),
    DocumentNumber VARCHAR(20),
    Email VARCHAR(150),
    HireDate DATE,
    Salary DECIMAL(12,2),
    IsActive BIT
);
GO

CREATE TABLE stg_Purchases (
    PurchaseID BIGINT,
    SupplierID INT,
    StoreID INT,
    PurchaseDate DATE,
    TotalPurchaseAmount DECIMAL(14,2),
    PurchaseYear INT,
    PurchaseMonth INT
);
GO

CREATE TABLE stg_PurchaseDetails (
    PurchaseDetailID BIGINT,
    PurchaseID BIGINT,
    ProductID INT,
    Quantity INT,
    UnitCost DECIMAL(12,2),
    TotalAmount DECIMAL(14,2),
    AverageCost DECIMAL(12,2)
);
GO

CREATE TABLE stg_Returns (
    ReturnID BIGINT,
    SaleID BIGINT,
    ProductID INT,
    ReturnDate DATE,
    Quantity INT,
    ReturnReason VARCHAR(255),
    RefundAmount DECIMAL(14,2)
);
GO

CREATE TABLE stg_SalesTargets (
    TargetID INT,
    StoreID INT,
    CategoryID INT,
    SalespersonID INT,
    YearNumber INT,
    MonthNumber INT,
    TargetAmount DECIMAL(14,2),
    QuarterlyTarget VARCHAR(20)
);
GO