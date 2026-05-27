-- Crear la base de datos del Data Warehouse
CREATE DATABASE DB_DW;
GO

USE DB_DW;
GO

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,           
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfWeek INT NOT NULL,            
    DayName VARCHAR(20) NOT NULL,
    WeekOfYear INT NOT NULL,
    IsWeekend BIT NOT NULL            
);

CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,  -- Clave sustituta
    CustomerID INT NOT NULL,                     -- ID original del OLTP
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50),
    Region VARCHAR(50),
    Segment VARCHAR(50),                         -- Ej: Oro, Plata, Bronce
    IsActive BIT DEFAULT 1,
    ValidFrom DATE,                              -- Para SCD Tipo 2
    ValidTo DATE,                                -- Para SCD Tipo 2
    IsCurrent BIT DEFAULT 1                      -- Para SCD Tipo 2
);

CREATE TABLE DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName VARCHAR(100),
    CategoryID INT,
    CategoryName VARCHAR(50),
    SupplierID INT,
    SupplierName VARCHAR(100),
    UnitPrice DECIMAL(18,2),
    IsActive BIT DEFAULT 1
);

CREATE TABLE DimStore (
    StoreKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    StoreName VARCHAR(100),
    StoreAddress VARCHAR(200),
    City VARCHAR(50),
    Region VARCHAR(50),
    StoreType VARCHAR(50),              -- Ej: Principal, Express, Sucursal
    IsActive BIT DEFAULT 1
);

CREATE TABLE DimSalesperson (
    SalespersonKey INT IDENTITY(1,1) PRIMARY KEY,
    SalespersonID INT NOT NULL,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    StoreID INT,                         -- Tienda a la que pertenece
    HireDate DATE,
    IsActive BIT DEFAULT 1
);

CREATE TABLE DimSupplier (
    SupplierKey INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    SupplierName VARCHAR(100),
    ContactName VARCHAR(100),
    City VARCHAR(50),
    Region VARCHAR(50),
    IsActive BIT DEFAULT 1
);

CREATE TABLE DimCategory (
    CategoryKey INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    CategoryName VARCHAR(50),
    ParentCategory VARCHAR(50)          -- Para jerarquías
);

CREATE TABLE DimCampaign (
    CampaignKey INT IDENTITY(1,1) PRIMARY KEY,
    CampaignID INT NOT NULL,
    CampaignName VARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    DiscountPercent DECIMAL(5,2)
);

CREATE TABLE DimSalesChannel (
    ChannelKey INT IDENTITY(1,1) PRIMARY KEY,
    ChannelID INT NOT NULL,
    ChannelName VARCHAR(50),
    ChannelType VARCHAR(50)             -- Ej: Físico, Online, App
);