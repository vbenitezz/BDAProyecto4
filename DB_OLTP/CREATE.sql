CREATE DATABASE DB_OLTP;
GO

USE DB_OLTP;
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(150) NOT NULL,
    TaxID VARCHAR(20) NOT NULL,
    City VARCHAR(100) NOT NULL,
    StateProvince VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(150),
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName VARCHAR(150) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    Phone VARCHAR(20),
    OpeningDate DATE,
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE Salespersons (
    SalespersonID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    FullName VARCHAR(150) NOT NULL,
    DocumentNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(150),
    HireDate DATE,
    Salary DECIMAL(12,2),
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Salespersons_Stores
        FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(150) NOT NULL,
    DocumentNumber VARCHAR(20) NOT NULL,
    Gender VARCHAR(20),
    BirthDate DATE,
    City VARCHAR(100),
    StateProvince VARCHAR(100),
    CustomerSegment VARCHAR(50),
    Email VARCHAR(150),
    Phone VARCHAR(20),
    RegistrationDate DATE NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CHK_Customers_Gender
        CHECK (Gender IN ('Male','Female','Other'))
);

CREATE TABLE SalesChannels (
    SalesChannelID INT IDENTITY(1,1) PRIMARY KEY,
    ChannelName VARCHAR(100) NOT NULL
);

CREATE TABLE Campaigns (
    CampaignID INT IDENTITY(1,1) PRIMARY KEY,
    CampaignName VARCHAR(150) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    DiscountPercentage DECIMAL(5,2)
);

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

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID),

    CONSTRAINT CHK_SalePrice
        CHECK (SalePrice > 0),

    CONSTRAINT CHK_UnitCost
        CHECK (UnitCost > 0)
);

CREATE TABLE Sales (
    SaleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    StoreID INT NOT NULL,
    SalespersonID INT NOT NULL,
    SalesChannelID INT NOT NULL,
    CampaignID INT NULL,
    SaleDate DATETIME NOT NULL,
    PaymentMethod VARCHAR(50),
    TotalSaleAmount DECIMAL(14,2),

    CONSTRAINT FK_Sales_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Sales_Stores
        FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID),

    CONSTRAINT FK_Sales_Salespersons
        FOREIGN KEY (SalespersonID)
        REFERENCES Salespersons(SalespersonID),

    CONSTRAINT FK_Sales_Channels
        FOREIGN KEY (SalesChannelID)
        REFERENCES SalesChannels(SalesChannelID),

    CONSTRAINT FK_Sales_Campaigns
        FOREIGN KEY (CampaignID)
        REFERENCES Campaigns(CampaignID)
);

CREATE TABLE SalesDetails (
    SaleDetailID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SaleID BIGINT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    UnitCost DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) DEFAULT 0,
    TotalAmount DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_SalesDetails_Sales
        FOREIGN KEY (SaleID)
        REFERENCES Sales(SaleID),

    CONSTRAINT FK_SalesDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CHK_Quantity
        CHECK (Quantity > 0)
);

CREATE TABLE DailyInventory (
    InventoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    StoreID INT NOT NULL,
    InventoryDate DATE NOT NULL,
    InitialStock INT NOT NULL,
    StockIn INT NOT NULL,
    StockOut INT NOT NULL,
    FinalStock INT NOT NULL,

    CONSTRAINT FK_DailyInventory_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_DailyInventory_Stores
        FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
);

CREATE TABLE Purchases (
    PurchaseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    StoreID INT NOT NULL,
    PurchaseDate DATE NOT NULL,
    TotalPurchaseAmount DECIMAL(14,2),

    CONSTRAINT FK_Purchases_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID),

    CONSTRAINT FK_Purchases_Stores
        FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID)
);

CREATE TABLE PurchaseDetails (
    PurchaseDetailID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PurchaseID BIGINT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitCost DECIMAL(12,2) NOT NULL,
    TotalAmount DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_PurchaseDetails_Purchases
        FOREIGN KEY (PurchaseID)
        REFERENCES Purchases(PurchaseID),

    CONSTRAINT FK_PurchaseDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE Returns (
    ReturnID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SaleID BIGINT NOT NULL,
    ProductID INT NOT NULL,
    ReturnDate DATE NOT NULL,
    Quantity INT NOT NULL,
    ReturnReason VARCHAR(255),
    RefundAmount DECIMAL(14,2),

    CONSTRAINT FK_Returns_Sales
        FOREIGN KEY (SaleID)
        REFERENCES Sales(SaleID),

    CONSTRAINT FK_Returns_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE SalesTargets (
    TargetID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    CategoryID INT NOT NULL,
    SalespersonID INT NULL,
    YearNumber INT NOT NULL,
    MonthNumber INT NOT NULL,
    TargetAmount DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_SalesTargets_Stores
        FOREIGN KEY (StoreID)
        REFERENCES Stores(StoreID),

    CONSTRAINT FK_SalesTargets_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_SalesTargets_Salespersons
        FOREIGN KEY (SalespersonID)
        REFERENCES Salespersons(SalespersonID)
);
