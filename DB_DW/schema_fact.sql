CREATE TABLE FactSales (
    SaleDetailKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Claves foráneas a dimensiones
    DateKey INT NOT NULL,               -- Fecha de venta
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    SalespersonKey INT NOT NULL,
    ChannelKey INT NOT NULL,
    CampaignKey INT NULL,               -- Puede ser NULL si no hubo campaña
    -- Medidas numéricas (aditivas)
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    TotalAmount DECIMAL(18,2) NOT NULL, -- Quantity * UnitPrice - Discount
    TotalCost DECIMAL(18,2) NOT NULL,   -- Quantity * UnitCost
    Profit DECIMAL(18,2) NOT NULL,      -- TotalAmount - TotalCost
    -- Metadatos de ETL
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE FactInventory (
    InventoryKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    -- Medidas (semi-aditivas: no sumar a través del tiempo)
    OpeningStock INT NOT NULL,          -- Inventario inicio del día
    QuantityIn INT NOT NULL,            -- Entradas del día
    QuantityOut INT NOT NULL,           -- Salidas del día
    ClosingStock INT NOT NULL,          -- Inventario final del día
    StockValue DECIMAL(18,2) NOT NULL,  -- Valor del inventario
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE FactSalesTargets (
    TargetKey INT IDENTITY(1,1) PRIMARY KEY,
    Year INT NOT NULL,
    Month INT NOT NULL,
    StoreKey INT NOT NULL,
    SalespersonKey INT NULL,            -- Puede ser NULL si meta es por tienda
    CategoryKey INT NULL,               -- Puede ser NULL si meta es por producto
    ProductKey INT NULL,                -- Puede ser NULL si meta es por categoría
    TargetAmount DECIMAL(18,2) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);