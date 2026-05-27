USE DB_DW;
GO

INSERT INTO FactSales (
    DateKey, CustomerKey, ProductKey, StoreKey, SalespersonKey, 
    ChannelKey, CampaignKey, Quantity, UnitPrice, UnitCost, 
    DiscountAmount, TotalAmount, TotalCost, Profit
)
SELECT 
    -- DateKey: convertir fecha a formato YYYYMMDD
    YEAR(s.SaleDate) * 10000 + MONTH(s.SaleDate) * 100 + DAY(s.SaleDate) AS DateKey,
    
    -- CustomerKey
    c.CustomerKey,
    
    -- ProductKey
    p.ProductKey,
    
    -- StoreKey
    st.StoreKey,
    
    -- SalespersonKey
    sp.SalespersonKey,
    
    -- ChannelKey
    ch.ChannelKey,
    
    -- CampaignKey (puede ser NULL si no hay campaña)
    cam.CampaignKey,
    
    -- Medidas
    sd.Quantity,
    sd.UnitPrice,
    sd.UnitCost,
    ISNULL(sd.DiscountAmount, 0) AS DiscountAmount,
    sd.TotalAmount,
    sd.Quantity * sd.UnitCost AS TotalCost,
    sd.TotalAmount - (sd.Quantity * sd.UnitCost) AS Profit
    
FROM DB_STAGING.dbo.stg_SalesDetails sd
INNER JOIN DB_STAGING.dbo.stg_Sales s ON sd.SaleID = s.SaleID
INNER JOIN DimCustomer c ON s.CustomerID = c.CustomerID AND c.IsCurrent = 1
INNER JOIN DimProduct p ON sd.ProductID = p.ProductID
INNER JOIN DimStore st ON s.StoreID = st.StoreID
INNER JOIN DimSalesperson sp ON s.SalespersonID = sp.SalespersonID
INNER JOIN DimSalesChannel ch ON s.SalesChannelID = ch.ChannelID
LEFT JOIN DimCampaign cam ON s.CampaignID = cam.CampaignID;
GO

-- Verificar
SELECT COUNT(*) AS TotalRegistrosFactSales FROM FactSales;
SELECT TOP 10 * FROM FactSales;

INSERT INTO FactInventory (
    DateKey, ProductKey, StoreKey, 
    OpeningStock, QuantityIn, QuantityOut, ClosingStock, StockValue
)
SELECT 
    -- DateKey
    YEAR(i.InventoryDate) * 10000 + MONTH(i.InventoryDate) * 100 + DAY(i.InventoryDate) AS DateKey,
    
    -- ProductKey
    p.ProductKey,
    
    -- StoreKey
    st.StoreKey,
    
    -- Medidas de inventario
    i.InitialStock AS OpeningStock,
    i.StockIn AS QuantityIn,
    i.StockOut AS QuantityOut,
    i.FinalStock AS ClosingStock,
    i.FinalStock * prod.SalePrice AS StockValue  -- Valor del inventario a precio de venta
    
FROM DB_STAGING.dbo.stg_DailyInventory i
INNER JOIN DimProduct p ON i.ProductID = p.ProductID
INNER JOIN DimStore st ON i.StoreID = st.StoreID
INNER JOIN DB_STAGING.dbo.stg_Products prod ON i.ProductID = prod.ProductID;
GO

-- Verificar
SELECT COUNT(*) AS TotalRegistrosFactInventory FROM FactInventory;
SELECT TOP 10 * FROM FactInventory;


INSERT INTO FactSalesTargets (
    Year, Month, StoreKey, SalespersonKey, CategoryKey, ProductKey, TargetAmount
)
SELECT 
    t.YearNumber AS Year,
    t.MonthNumber AS Month,
    s.StoreKey,
    sp.SalespersonKey,
    c.CategoryKey,
    NULL AS ProductKey,  -- Meta por categoría, no por producto específico
    t.TargetAmount
FROM DB_STAGING.dbo.stg_SalesTargets t
INNER JOIN DimStore s ON t.StoreID = s.StoreID
LEFT JOIN DimSalesperson sp ON t.SalespersonID = sp.SalespersonID
LEFT JOIN DimCategory c ON t.CategoryID = c.CategoryID
WHERE t.TargetAmount IS NOT NULL AND t.TargetAmount > 0;
GO

-- Verificar
SELECT COUNT(*) AS TotalRegistrosFactSalesTargets FROM FactSalesTargets;
SELECT TOP 10 * FROM FactSalesTargets;

SELECT 'FactSales' AS TablaHechos, COUNT(*) AS Registros FROM FactSales
UNION ALL
SELECT 'FactInventory', COUNT(*) FROM FactInventory
UNION ALL
SELECT 'FactSalesTargets', COUNT(*) FROM FactSalesTargets;