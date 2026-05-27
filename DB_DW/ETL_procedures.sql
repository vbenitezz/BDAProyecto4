USE DB_DW;
GO

CREATE OR ALTER PROCEDURE sp_CargarDimDate
    @StartDate DATE = '2020-01-01',
    @EndDate DATE = '2026-12-31'
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarDimDate', @StartTime, @Status, 0, 0, 0);

        DECLARE @TotalDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
        SET @RowsRead = @TotalDays;

        DELETE FROM FactSales WHERE DateKey IS NOT NULL;
        DELETE FROM FactInventory WHERE DateKey IS NOT NULL;

        DELETE FROM DimDate;

        WITH DateRange AS (
            SELECT @StartDate AS DateValue
            UNION ALL
            SELECT DATEADD(DAY, 1, DateValue)
            FROM DateRange
            WHERE DateValue < @EndDate
        )
        INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfMonth, DayOfWeek, DayName, WeekOfYear, IsWeekend)
        SELECT 
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

        SET @RowsLoaded = @@ROWCOUNT;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimDate' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimDate' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_CargarDimCustomer
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarDimCustomer', @StartTime, @Status, 0, 0, 0);

        SELECT @RowsRead = COUNT(*) FROM DB_STAGING.dbo.stg_Customers;

        DELETE FROM FactSales WHERE CustomerKey IS NOT NULL;
        DELETE FROM FactSalesTargets WHERE SalespersonKey IS NOT NULL;
        
        DELETE FROM DimCustomer;
        DBCC CHECKIDENT ('DimCustomer', RESEED, 0);

        INSERT INTO DimCustomer (CustomerID, CustomerName, Email, City, Region, Segment, IsActive, ValidFrom, ValidTo, IsCurrent)
        SELECT 
            CustomerID,
            FullName AS CustomerName,
            Email,
            ISNULL(City, 'No especificada') AS City,
            ISNULL(StateProvince, 'No especificada') AS Region,
            CustomerSegment AS Segment,
            1 AS IsActive,
            GETDATE() AS ValidFrom,
            '9999-12-31' AS ValidTo,
            1 AS IsCurrent
        FROM DB_STAGING.dbo.stg_Customers;

        SET @RowsLoaded = @@ROWCOUNT;
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimCustomer' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimCustomer' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_CargarDimProduct
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarDimProduct', @StartTime, @Status, 0, 0, 0);

        SELECT @RowsRead = COUNT(*) FROM DB_STAGING.dbo.stg_Products;

        DELETE FROM FactSales WHERE ProductKey IS NOT NULL;
        DELETE FROM FactInventory WHERE ProductKey IS NOT NULL;
        DELETE FROM FactSalesTargets WHERE ProductKey IS NOT NULL;

        DELETE FROM DimProduct;
        DBCC CHECKIDENT ('DimProduct', RESEED, 0);

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

        SET @RowsLoaded = @@ROWCOUNT;
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimProduct' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarDimProduct' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_CargarFactVentas
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarFactVentas', @StartTime, @Status, 0, 0, 0);

        SELECT @RowsRead = COUNT(*) FROM DB_STAGING.dbo.stg_SalesDetails;

        TRUNCATE TABLE FactSales;

        INSERT INTO FactSales (
            DateKey, CustomerKey, ProductKey, StoreKey, SalespersonKey, 
            ChannelKey, CampaignKey, Quantity, UnitPrice, UnitCost, 
            DiscountAmount, TotalAmount, TotalCost, Profit
        )
        SELECT 
            YEAR(s.SaleDate) * 10000 + MONTH(s.SaleDate) * 100 + DAY(s.SaleDate) AS DateKey,
            c.CustomerKey,
            p.ProductKey,
            st.StoreKey,
            sp.SalespersonKey,
            ch.ChannelKey,
            cam.CampaignKey,
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

        SET @RowsLoaded = @@ROWCOUNT;
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactVentas' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactVentas' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_CargarFactInventario
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarFactInventario', @StartTime, @Status, 0, 0, 0);

        SELECT @RowsRead = COUNT(*) FROM DB_STAGING.dbo.stg_DailyInventory;

        TRUNCATE TABLE FactInventory;

        INSERT INTO FactInventory (DateKey, ProductKey, StoreKey, OpeningStock, QuantityIn, QuantityOut, ClosingStock, StockValue)
        SELECT 
            YEAR(i.InventoryDate) * 10000 + MONTH(i.InventoryDate) * 100 + DAY(i.InventoryDate) AS DateKey,
            p.ProductKey,
            st.StoreKey,
            i.InitialStock AS OpeningStock,
            i.StockIn AS QuantityIn,
            i.StockOut AS QuantityOut,
            i.FinalStock AS ClosingStock,
            i.FinalStock * prod.SalePrice AS StockValue
        FROM DB_STAGING.dbo.stg_DailyInventory i
        INNER JOIN DimProduct p ON i.ProductID = p.ProductID
        INNER JOIN DimStore st ON i.StoreID = st.StoreID
        INNER JOIN DB_STAGING.dbo.stg_Products prod ON i.ProductID = prod.ProductID;

        SET @RowsLoaded = @@ROWCOUNT;
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactInventario' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactInventario' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_CargarFactMetas
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('CargarFactMetas', @StartTime, @Status, 0, 0, 0);

        SELECT @RowsRead = COUNT(*) FROM DB_STAGING.dbo.stg_SalesTargets WHERE TargetAmount IS NOT NULL;

        TRUNCATE TABLE FactSalesTargets;

        INSERT INTO FactSalesTargets (Year, Month, StoreKey, SalespersonKey, CategoryKey, ProductKey, TargetAmount)
        SELECT 
            t.YearNumber AS Year,
            t.MonthNumber AS Month,
            s.StoreKey,
            sp.SalespersonKey,
            c.CategoryKey,
            NULL AS ProductKey,
            t.TargetAmount
        FROM DB_STAGING.dbo.stg_SalesTargets t
        INNER JOIN DimStore s ON t.StoreID = s.StoreID
        LEFT JOIN DimSalesperson sp ON t.SalespersonID = sp.SalespersonID
        LEFT JOIN DimCategory c ON t.CategoryID = c.CategoryID
        WHERE t.TargetAmount IS NOT NULL AND t.TargetAmount > 0;

        SET @RowsLoaded = @@ROWCOUNT;
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactMetas' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'CargarFactMetas' AND StartDate = @StartTime AND Status = 'In Progress';
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_ValidarCalidadDatos
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @RowsRead INT = 0;
    DECLARE @RowsLoaded INT = 0;
    DECLARE @RowsRejected INT = 0;
    DECLARE @Status VARCHAR(20) = 'In Progress';
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;
    DECLARE @ValidationResults TABLE (ValidationName VARCHAR(100), Result VARCHAR(500));

    BEGIN TRY
        INSERT INTO ETL_Log (ProcessName, StartDate, Status, RowsRead, RowsLoaded, RowsRejected)
        VALUES ('ValidarCalidadDatos', @StartTime, @Status, 0, 0, 0);

        -- Validación 1: Verificar que no haya NULLs en claves foráneas de FactSales
        INSERT INTO @ValidationResults
        SELECT 'FK_NULL_Validation_FactSales', 
               CASE WHEN COUNT(*) > 0 THEN 'WARNING: ' + CAST(COUNT(*) AS VARCHAR) + ' registros con claves foráneas NULL en FactSales' ELSE 'OK' END
        FROM FactSales 
        WHERE DateKey IS NULL OR CustomerKey IS NULL OR ProductKey IS NULL OR StoreKey IS NULL;

        -- Validación 2: Verificar que no haya cantidades negativas
        INSERT INTO @ValidationResults
        SELECT 'Negative_Quantity_Validation',
               CASE WHEN COUNT(*) > 0 THEN 'ERROR: ' + CAST(COUNT(*) AS VARCHAR) + ' ventas con cantidad negativa' ELSE 'OK' END
        FROM FactSales WHERE Quantity < 0;

        -- Validación 3: Verificar que las fechas en FactSales existan en DimDate
        INSERT INTO @ValidationResults
        SELECT 'Orphan_Dates_Validation',
               CASE WHEN COUNT(*) > 0 THEN 'ERROR: ' + CAST(COUNT(*) AS VARCHAR) + ' fechas sin correspondencia en DimDate' ELSE 'OK' END
        FROM FactSales f
        LEFT JOIN DimDate d ON f.DateKey = d.DateKey
        WHERE d.DateKey IS NULL;

        -- Validación 4: Verificar inventario negativo
        INSERT INTO @ValidationResults
        SELECT 'Negative_Inventory_Validation',
               CASE WHEN COUNT(*) > 0 THEN 'ERROR: ' + CAST(COUNT(*) AS VARCHAR) + ' registros con stock final negativo' ELSE 'OK' END
        FROM FactInventory WHERE ClosingStock < 0;

        -- Validación 5: Verificar márgenes de ganancia lógicos (entre 0% y 100%)
        INSERT INTO @ValidationResults
        SELECT 'Profit_Margin_Validation',
               CASE WHEN COUNT(*) > 0 THEN 'WARNING: ' + CAST(COUNT(*) AS VARCHAR) + ' ventas con margen fuera de rango [0-100]%' ELSE 'OK' END
        FROM FactSales 
        WHERE (Profit / NULLIF(TotalAmount, 0)) < 0 OR (Profit / NULLIF(TotalAmount, 0)) > 1;

        -- Validación 6: Contar registros por tabla
        INSERT INTO @ValidationResults
        SELECT 'Row_Count_FactSales', CAST(COUNT(*) AS VARCHAR) + ' registros' FROM FactSales;
        
        INSERT INTO @ValidationResults
        SELECT 'Row_Count_FactInventory', CAST(COUNT(*) AS VARCHAR) + ' registros' FROM FactInventory;
        
        INSERT INTO @ValidationResults
        SELECT 'Row_Count_FactSalesTargets', CAST(COUNT(*) AS VARCHAR) + ' registros' FROM FactSalesTargets;

        -- Mostrar resultados de validación
        SELECT * FROM @ValidationResults;

        SET @RowsRead = (SELECT COUNT(*) FROM @ValidationResults);
        SET @RowsLoaded = (SELECT COUNT(*) FROM @ValidationResults WHERE Result = 'OK');
        SET @RowsRejected = @RowsRead - @RowsLoaded;
        SET @Status = 'Success';

        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, RowsRead = @RowsRead,
            RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'ValidarCalidadDatos' AND StartDate = @StartTime AND Status = 'In Progress';

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ETL_Log 
        SET EndDate = GETDATE(), Status = @Status, ErrorMessage = @ErrorMessage,
            RowsRead = @RowsRead, RowsLoaded = @RowsLoaded, RowsRejected = @RowsRejected
        WHERE ProcessName = 'ValidarCalidadDatos' AND StartDate = @StartTime AND Status = 'In Progress';
        
        SELECT 'ERROR' AS Status, @ErrorMessage AS Message;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_CrearLlavesForaneas
AS
BEGIN
    -- FactSales
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimSalesperson FOREIGN KEY (SalespersonKey) REFERENCES DimSalesperson(SalespersonKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimSalesChannel FOREIGN KEY (ChannelKey) REFERENCES DimSalesChannel(ChannelKey);
    ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimCampaign FOREIGN KEY (CampaignKey) REFERENCES DimCampaign(CampaignKey);

    -- FactInventory
    ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey);
    ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
    ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);

    -- FactSalesTargets
    ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);
    ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimSalesperson FOREIGN KEY (SalespersonKey) REFERENCES DimSalesperson(SalespersonKey);
    ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimCategory FOREIGN KEY (CategoryKey) REFERENCES DimCategory(CategoryKey);
    ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
END;
GO

USE DB_DW;
GO

CREATE OR ALTER PROCEDURE sp_EjecutarTodoETL
AS
BEGIN
    PRINT '========================================';
    PRINT 'Iniciando proceso ETL completo';
    PRINT '========================================';
    
    -- 1. Eliminar llaves foráneas
    PRINT 'Eliminando llaves foráneas...';
	ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimDate;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimCustomer;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimProduct;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimStore;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimSalesperson;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimSalesChannel;
    ALTER TABLE FactSales DROP CONSTRAINT IF EXISTS FK_FactSales_DimCampaign;
    ALTER TABLE FactInventory DROP CONSTRAINT IF EXISTS FK_FactInventory_DimDate;
    ALTER TABLE FactInventory DROP CONSTRAINT IF EXISTS FK_FactInventory_DimProduct;
    ALTER TABLE FactInventory DROP CONSTRAINT IF EXISTS FK_FactInventory_DimStore;
    ALTER TABLE FactSalesTargets DROP CONSTRAINT IF EXISTS FK_FactTargets_DimStore;
    ALTER TABLE FactSalesTargets DROP CONSTRAINT IF EXISTS FK_FactTargets_DimSalesperson;
    ALTER TABLE FactSalesTargets DROP CONSTRAINT IF EXISTS FK_FactTargets_DimCategory;
    ALTER TABLE FactSalesTargets DROP CONSTRAINT IF EXISTS FK_FactTargets_DimProduct;
    
    PRINT '✓ Llaves foráneas eliminadas';

    
    -- 2. Cargar dimensiones (vacían los hechos primero automáticamente)
    EXEC sp_CargarDimDate;
    PRINT '✓ DimDate cargada';
    
    EXEC sp_CargarDimCustomer;
    PRINT '✓ DimCustomer cargada';
    
    EXEC sp_CargarDimProduct;
    PRINT '✓ DimProduct cargada';
    
    -- 3. Cargar hechos
    EXEC sp_CargarFactVentas;
    PRINT '✓ FactVentas cargada';
    
    EXEC sp_CargarFactInventario;
    PRINT '✓ FactInventory cargada';
    
    EXEC sp_CargarFactMetas;
    PRINT '✓ FactMetas cargada';
    
    -- 4. Recrear llaves foráneas
    PRINT 'Recreando llaves foráneas...';
    EXEC sp_CrearLlavesForaneas;
    
    -- 5. Validar calidad
    EXEC sp_ValidarCalidadDatos;
    PRINT '✓ Validación de calidad completada';

    PRINT '✓ Creando llaves foráneas';
    EXEC sp_CrearLlavesForaneas;   
    PRINT '✓ llaves foráneas creadas';


    
    PRINT '========================================';
    PRINT 'ETL completado. Revisar tabla ETL_Log';
    PRINT '========================================';
END;
GO

EXEC sp_EjecutarTodoETL;
GO

-- Ver resultados
SELECT * FROM ETL_Log ORDER BY LogID DESC;