USE DB_OLTP;
GO

DELETE FROM Categories;
DBCC CHECKIDENT ('Categories', RESEED, 0);


/* =========================================================
   CATEGORIES
   - Inconsistencias:
     * mayúsculas/minúsculas
     * espacios extras
     * nombres duplicados
========================================================= */

INSERT INTO Categories (CategoryName, Description)
VALUES
('Tecnología', 'Equipos tecnológicos'),
('tecnologia', 'Artículos de tecnología'),
(' TECNOLOGIA ', 'Productos electrónicos'),
('Hogar', 'Productos para el hogar'),
('hogar ', 'Artículos hogar'),
('ROPA', 'Vestuario'),
('Ropa', 'Moda y vestuario'),
('Deportes', 'Artículos deportivos'),
('deportes ', 'Implementos deportivos'),
('Belleza', 'Productos de belleza');


/* =========================================================
   SALES CHANNELS
========================================================= */

INSERT INTO SalesChannels (ChannelName)
VALUES
('Tienda Física'),
('Pagina Web'),
('Aplicación Móvil'),
('Marketplace'),
('marketplace');


/* =========================================================
   STORES
   - Inconsistencias:
     * ciudades inconsistentes
     * regiones inconsistentes
     * nulos
========================================================= */

INSERT INTO Stores
(StoreName, City, Region, Address, Phone, OpeningDate)
VALUES
('Tienda Medellín Centro','Medellin','Antioquia','Cra 45 #50-20','3001111111','2020-01-01'),
('Tienda Medellín Norte','MEDELLIN ','antioquia','Cra 65 #80-10','3001111112','01/02/2020'),
('Tienda Bogotá Norte','Bogotá','Cundinamarca','Calle 100 #15-20','3001111113','2020/03/01'),
('Tienda Bogotá Sur',' bogota ','CUNDINAMARCA','Cra 30 #20-10',NULL,'2020-04-01'),
('Tienda Cali Centro','Cali','Valle del Cauca','Av 5 Norte','3001111115','05-01-2020'),
('Tienda Barranquilla','BARRANQUILLA','Atlantico','Calle 84','3001111116','2020-06-01'),
('Tienda Cartagena','Cartagena ','Bolivar','Bocagrande','3001111117','2020-07-01'),
('Tienda Bucaramanga','bucaramanga','Santander',NULL,'3001111118','2020-08-01'),
('Tienda Pereira',' Pereira','Risaralda','Centro','3001111119','2020-09-01'),
('Tienda Manizales','MANIZALES','CALDAS','Zona Rosa','3001111120','2020-10-01');


/* =========================================================
   SUPPLIERS
   - Inconsistencias:
     * nulos
     * ciudades inconsistentes
     * emails inconsistentes
========================================================= */

DECLARE @i INT = 1;

WHILE @i <= 30
BEGIN

    INSERT INTO Suppliers
    (
        SupplierName,
        TaxID,
        City,
        StateProvince,
        Phone,
        Email
    )
    VALUES
    (
        CONCAT('Proveedor ', @i),

        CONCAT('900', RIGHT('00000'+CAST(@i AS VARCHAR),5)),

        CASE
            WHEN @i % 4 = 0 THEN 'medellin'
            WHEN @i % 4 = 1 THEN 'MEDELLIN'
            WHEN @i % 4 = 2 THEN ' Medellín '
            ELSE 'Medellin'
        END,

        CASE
            WHEN @i % 3 = 0 THEN 'antioquia'
            WHEN @i % 3 = 1 THEN 'ANTIOQUIA'
            ELSE 'Antioquia '
        END,

        CASE
            WHEN @i % 5 = 0 THEN NULL
            ELSE CONCAT('300555',RIGHT('0000'+CAST(@i AS VARCHAR),4))
        END,

        CASE
            WHEN @i % 6 = 0 THEN NULL
            WHEN @i % 2 = 0 THEN CONCAT('PROVEEDOR',@i,'@CORREO.COM')
            ELSE CONCAT('proveedor',@i,'@correo.com ')
        END
    );

    SET @i = @i + 1;
END;


/* =========================================================
   CUSTOMERS
   - Inconsistencias:
     * duplicados
     * nulos
     * ciudades inconsistentes
     * géneros inconsistentes
========================================================= */
DECLARE @counter INT = 1;

WHILE @counter <= 1000
BEGIN

    INSERT INTO Customers
    (
        FullName,
        DocumentNumber,
        Gender,
        BirthDate,
        City,
        StateProvince,
        CustomerSegment,
        Email,
        Phone
    )
    VALUES
    (
        CONCAT('Cliente ', @counter),

        CASE
            WHEN @counter % 100 = 0
                THEN CONCAT('10', RIGHT('00000000'+CAST(@counter-1 AS VARCHAR),8))
            ELSE CONCAT('10', RIGHT('00000000'+CAST(@counter AS VARCHAR),8))
        END,

        CASE
            WHEN @counter % 4 = 0 THEN 'Male'
            WHEN @counter % 4 = 1 THEN 'Female'
            WHEN @counter % 4 = 2 THEN 'male'
            ELSE 'Other'
        END,

        DATEADD(DAY, -(@counter*20), GETDATE()),

        CASE
            WHEN @counter % 5 = 0 THEN 'medellin'
            WHEN @counter % 5 = 1 THEN 'MEDELLIN'
            WHEN @counter % 5 = 2 THEN ' Medellín '
            WHEN @counter % 5 = 3 THEN 'Bogota'
            ELSE 'bogotá '
        END,

        CASE
            WHEN @counter % 3 = 0 THEN 'Antioquia'
            WHEN @counter % 3 = 1 THEN ' antioquia '
            ELSE 'CUNDINAMARCA'
        END,

        CASE
            WHEN @counter % 3 = 0 THEN 'Premium'
            WHEN @counter % 3 = 1 THEN 'regular'
            ELSE 'CORPORATIVO'
        END,

        CASE
            WHEN @counter % 10 = 0 THEN NULL
            ELSE CONCAT('cliente',@counter,'@correo.com ')
        END,

        CASE
            WHEN @counter % 15 = 0 THEN NULL
            ELSE CONCAT('300',RIGHT('0000000'+CAST(@counter AS VARCHAR),7))
        END
    );

    SET @counter = @counter + 1;
END;
GO

select count(*) from Customers;


/* =========================================================
   SALESPERSONS
========================================================= */

DECLARE @salesperson INT = 1;

WHILE @salesperson <= 20
BEGIN

    INSERT INTO Salespersons
    (
        StoreID,
        FullName,
        DocumentNumber,
        Email,
        HireDate,
        Salary
    )
    VALUES
    (
        ((@salesperson - 1) % 10) + 1,

        CONCAT('Vendedor ', @salesperson),

        CONCAT('80', RIGHT('000000'+CAST(@salesperson AS VARCHAR),6)),

        CASE
            WHEN @salesperson % 4 = 0 THEN NULL
            ELSE CONCAT('vendedor',@salesperson,'@empresa.com')
        END,

        GETDATE(),

        2000000 + (@salesperson * 100000)
    );

    SET @salesperson = @salesperson + 1;
END;

/* =========================================================
   PURCHASES
========================================================= */

DELETE FROM Purchases;
DBCC CHECKIDENT ('Purchases', RESEED, 0);
GO


DECLARE @purchase INT = 1;

WHILE @purchase <= 5000
BEGIN

    INSERT INTO Purchases
    (
        SupplierID,
        StoreID,
        PurchaseDate,
        TotalPurchaseAmount
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 30 + 1,

        ABS(CHECKSUM(NEWID())) % 10 + 1,

        DATEADD(DAY,-ABS(CHECKSUM(NEWID())) % 365,GETDATE()),

        RAND(CHECKSUM(NEWID())) * 10000000 + 500000
    );

    SET @purchase = @purchase + 1;
END;
GO

SELECT COUNT(*) FROM Purchases;


/* =========================================================
   PURCHASE DETAILS
========================================================= */
SELECT COUNT(*) FROM PurchaseDetails;

DELETE FROM PurchaseDetails;
DBCC CHECKIDENT ('PurchaseDetails', RESEED, 0);
GO


DECLARE @purchaseDetail INT = 1;

WHILE @purchaseDetail <= 20000
BEGIN

    DECLARE @PurchaseProductID INT;
    DECLARE @PurchaseQuantity INT;
    DECLARE @PurchaseCost DECIMAL(12,2);

    SET @PurchaseProductID =
        (SELECT TOP 1 ProductID
         FROM Products
         ORDER BY NEWID());

    SET @PurchaseQuantity =
        ABS(CHECKSUM(NEWID())) % 10 + 1;

    SELECT
        @PurchaseCost = UnitCost
    FROM Products
    WHERE ProductID = @PurchaseProductID;

    INSERT INTO PurchaseDetails
    (
        PurchaseID,
        ProductID,
        Quantity,
        UnitCost,
        TotalAmount
    )
    VALUES
    (
        (SELECT TOP 1 PurchaseID
         FROM Purchases
         ORDER BY NEWID()),

        @PurchaseProductID,

        @PurchaseQuantity,

        @PurchaseCost,

        @PurchaseQuantity * @PurchaseCost
    );

    SET @purchaseDetail = @purchaseDetail + 1;
END;
GO

/* =========================================================
   RETURNS
========================================================= */

DELETE FROM Returns;
DBCC CHECKIDENT ('Returns', RESEED, 0);
GO

SELECT COUNT(*) FROM Returns;

DECLARE @return INT = 1;

WHILE @return <= 3000
BEGIN

    INSERT INTO Returns
    (
        SaleID,
        ProductID,
        ReturnDate,
        Quantity,
        ReturnReason,
        RefundAmount
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 50000 + 1,

        ABS(CHECKSUM(NEWID())) % 200 + 1,

        DATEADD(DAY,-ABS(CHECKSUM(NEWID())) % 180,GETDATE()),

        ABS(CHECKSUM(NEWID())) % 3 + 1,

        CASE
            WHEN @return % 4 = 0 THEN 'Producto defectuoso'
            WHEN @return % 4 = 1 THEN 'Entrega tardía'
            WHEN @return % 4 = 2 THEN 'Error en talla'
            ELSE 'No cumplió expectativas'
        END,

        RAND(CHECKSUM(NEWID())) * 500000 + 10000
    );

    SET @return = @return + 1;
END;
GO


/* =========================================================
   PRODUCT
========================================================= */

DECLARE @product INT = 1;

WHILE @product <= 200
BEGIN

    INSERT INTO Products
    (
        CategoryID,
        SupplierID,
        ProductName,
        Brand,
        SKU,
        SalePrice,
        UnitCost
    )
    VALUES
    (
        ((@product -1) % 10) + 1,

        ((@product -1) % 30) + 1,

        CONCAT('Producto ', @product),

        CASE
            WHEN @product % 7 = 0 THEN NULL
            WHEN @product % 2 = 0 THEN CONCAT('Marca ', ((@product -1) % 10) + 1)
            ELSE CONCAT(' marca ', ((@product -1) % 10) + 1, ' ')
        END,

        CONCAT('SKU-', @product),

        RAND(CHECKSUM(NEWID())) * 500000 + 10000,

        RAND(CHECKSUM(NEWID())) * 300000 + 5000
    );

    SET @product = @product + 1;
END;
GO


/* =========================================================
   SALES
   - Inconsistencias:
     * métodos de pago inconsistentes
     * fechas variadas
========================================================= */

DECLARE @sale INT = 1;

WHILE @sale <= 50000
BEGIN

    INSERT INTO Sales
    (
        CustomerID,
        StoreID,
        SalespersonID,
        SalesChannelID,
        CampaignID,
        SaleDate,
        PaymentMethod,
        TotalSaleAmount
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        ABS(CHECKSUM(NEWID())) % 10 + 1,

        ABS(CHECKSUM(NEWID())) % 20 + 1,

        ABS(CHECKSUM(NEWID())) % 5 + 1,

        CASE
            WHEN @sale % 4 = 0 THEN NULL
            ELSE ABS(CHECKSUM(NEWID())) % 5 + 1
        END,

        DATEADD(DAY,-ABS(CHECKSUM(NEWID())) % 365,GETDATE()),

        CASE
            WHEN @sale % 5 = 0 THEN 'Tarjeta'
            WHEN @sale % 5 = 1 THEN 'tarjeta'
            WHEN @sale % 5 = 2 THEN 'EFECTIVO'
            WHEN @sale % 5 = 3 THEN 'Efectivo '
            ELSE 'Transferencia'
        END,

        0
    );

    SET @sale = @sale + 1;
END;
GO


/* =========================================================
   SALES DETAILS
   - Campos derivados:
     * profit
     * margen
========================================================= */

DECLARE @detail INT = 1;

WHILE @detail <= 150000
BEGIN

    DECLARE @ProductID INT;
    DECLARE @Quantity INT;
    DECLARE @Price DECIMAL(12,2);
    DECLARE @Cost DECIMAL(12,2);

    SET @ProductID = ABS(CHECKSUM(NEWID())) % 200 + 1;

    SET @Quantity = ABS(CHECKSUM(NEWID())) % 5 + 1;

    SELECT
        @Price = SalePrice,
        @Cost = UnitCost
    FROM Products
    WHERE ProductID = @ProductID;

    INSERT INTO SalesDetails
    (
        SaleID,
        ProductID,
        Quantity,
        UnitPrice,
        UnitCost,
        DiscountAmount,
        TotalAmount
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 50000 + 1,

        @ProductID,

        @Quantity,

        @Price,

        @Cost,

        CASE
            WHEN @detail % 10 = 0 THEN 5000
            ELSE 0
        END,

        (@Quantity * @Price)
    );

    SET @detail = @detail + 1;
END;
GO

UPDATE S
SET TotalSaleAmount = X.Total
FROM Sales S
INNER JOIN
(
    SELECT
        SaleID,
        SUM(TotalAmount) AS Total
    FROM SalesDetails
    GROUP BY SaleID
) X
ON S.SaleID = X.SaleID;
GO

/* =========================================================
   UPDATE TOTAL SALES
========================================================= */

UPDATE S
SET TotalSaleAmount = X.Total
FROM Sales S
INNER JOIN
(
    SELECT
        SaleID,
        SUM(TotalAmount) AS Total
    FROM SalesDetails
    GROUP BY SaleID
) X
ON S.SaleID = X.SaleID;


/* =========================================================
   DAILY INVENTORY
========================================================= */
DELETE FROM DailyInventory;

DBCC CHECKIDENT ('DailyInventory', RESEED, 0);
GO

DECLARE @InventoryDate DATE = '2025-01-01';

WHILE @InventoryDate <= '2025-12-31'
BEGIN

    INSERT INTO DailyInventory
    (
        ProductID,
        StoreID,
        InventoryDate,
        InitialStock,
        StockIn,
        StockOut,
        FinalStock
    )
    SELECT
        P.ProductID,

        S.StoreID,

        @InventoryDate,

        100,

        ABS(CHECKSUM(NEWID())) % 20,

        ABS(CHECKSUM(NEWID())) % 15,

        100 + ABS(CHECKSUM(NEWID())) % 20
            - ABS(CHECKSUM(NEWID())) % 15

    FROM Products P
    CROSS JOIN Stores S;

    SET @InventoryDate = DATEADD(DAY,1,@InventoryDate);
END;

SELECT COUNT(*) FROM DailyInventory;


/* =========================================================
   SALES TARGETS
========================================================= */

DECLARE @Month INT = 1;

WHILE @Month <= 12
BEGIN

    INSERT INTO SalesTargets
    (
        StoreID,
        CategoryID,
        SalespersonID,
        YearNumber,
        MonthNumber,
        TargetAmount
    )
    SELECT
        S.StoreID,

        C.CategoryID,

        NULL,

        2025,

        @Month,

        50000000 + ABS(CHECKSUM(NEWID())) % 50000000

    FROM Stores S
    CROSS JOIN Categories C;

    SET @Month = @Month + 1;
END;

/* =========================================================
   CAMPAIGNS
========================================================= */

INSERT INTO Campaigns
(
    CampaignName,
    StartDate,
    EndDate,
    DiscountPercentage
)
VALUES
('Black Friday 2025','2025-11-20','2025-11-30',25),
('Navidad 2025','2025-12-01','2025-12-31',15),
('Regreso a Clases','2025-01-10','2025-02-15',10),
('Semana Tecnológica','2025-06-01','2025-06-10',20),
('Cyber Days','2025-09-15','2025-09-20',18);
GO