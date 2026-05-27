USE DB_STAGING;
GO

/*CATEGORIES*/

WITH CleanCategories AS
(
    SELECT
        CategoryID,

        UPPER(LTRIM(RTRIM(CategoryName))) AS CategoryName,

        LTRIM(RTRIM(Description)) AS Description,

        IsActive,

        CreatedDate,

        ROW_NUMBER() OVER
        (
            PARTITION BY
            UPPER(LTRIM(RTRIM(CategoryName)))
            COLLATE Latin1_General_CI_AI

            ORDER BY CategoryID
        ) AS rn

    FROM DB_OLTP.dbo.Categories
)

INSERT INTO stg_Categories
(
    CategoryID,
    CategoryName,
    Description,
    IsActive,
    CreatedDate
)
SELECT
    CategoryID,

    CategoryName,

    Description,

    IsActive,

    CreatedDate

FROM CleanCategories
WHERE rn = 1;
GO


/*CUSTOMERS*/

DELETE FROM stg_Customers;
GO

ALTER TABLE stg_Customers
DROP COLUMN Age;
GO

INSERT INTO stg_Customers
SELECT
    CustomerID,

    LTRIM(RTRIM(FullName)),

    DocumentNumber,

    CASE
        WHEN UPPER(Gender) = 'MALE' THEN 'Male'
        WHEN UPPER(Gender) = 'FEMALE' THEN 'Female'
        ELSE 'Other'
    END,

    CAST(BirthDate AS DATE),

    CASE
        WHEN UPPER(LTRIM(RTRIM(City))) IN ('MEDELLIN','MEDELLÍN')
            THEN 'Medellín'

        WHEN UPPER(LTRIM(RTRIM(City))) IN ('BOGOTA','BOGOTÁ')
            THEN 'Bogotá'

        ELSE LTRIM(RTRIM(City))
    END,

    CASE
        WHEN UPPER(LTRIM(RTRIM(StateProvince))) = 'ANTIOQUIA'
            THEN 'Antioquia'

        WHEN UPPER(LTRIM(RTRIM(StateProvince))) = 'CUNDINAMARCA'
            THEN 'Cundinamarca'

        ELSE LTRIM(RTRIM(StateProvince))
    END,

    UPPER(LTRIM(RTRIM(CustomerSegment))),

    ISNULL(
        LTRIM(RTRIM(Email)),
        'sin_correo@correo.com'
    ),

    ISNULL(
        Phone,
        '0000000000'
    ),

    RegistrationDate

FROM DB_OLTP.dbo.Customers;
GO


/*PRODUCTS*/

INSERT INTO stg_Products
SELECT
    ProductID,

    CategoryID,

    SupplierID,

    LTRIM(RTRIM(ProductName)),

    ISNULL(
        UPPER(LTRIM(RTRIM(Brand))),
        'SIN MARCA'
    ),

    UPPER(LTRIM(RTRIM(SKU))),

    SalePrice,

    UnitCost,

    (SalePrice - UnitCost) AS ProfitMargin,

    IsActive

FROM DB_OLTP.dbo.Products;
GO


/*STORES*/

DELETE FROM stg_Stores;
GO

INSERT INTO stg_Stores
(
    StoreID,
    StoreName,
    City,
    Region,
    Address,
    Phone,
    OpeningDate,
    IsActive
)

SELECT
    StoreID,

    -----------------------------------
    -- LIMPIEZA NOMBRE TIENDA
    -----------------------------------
    LTRIM(RTRIM(StoreName)),

    -----------------------------------
    -- ESTANDARIZACIÓN CIUDADES
    -----------------------------------
    CASE
        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'MEDELLIN'
            THEN 'Medellín'

        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'BOGOTA'
            THEN 'Bogotá'

        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'BARRANQUILLA'
            THEN 'Barranquilla'

        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'BUCARAMANGA'
            THEN 'Bucaramanga'

        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'MANIZALES'
            THEN 'Manizales'

        ELSE
            LTRIM(RTRIM(City))
    END,

    -----------------------------------
    -- ESTANDARIZACIÓN REGIONES
    -----------------------------------
    CASE
        WHEN UPPER(LTRIM(RTRIM(Region)))
            COLLATE Latin1_General_CI_AI = 'ANTIOQUIA'
            THEN 'Antioquia'

        WHEN UPPER(LTRIM(RTRIM(Region)))
            COLLATE Latin1_General_CI_AI = 'CUNDINAMARCA'
            THEN 'Cundinamarca'

        WHEN UPPER(LTRIM(RTRIM(Region)))
            COLLATE Latin1_General_CI_AI = 'ATLANTICO'
            THEN 'Atlántico'

        WHEN UPPER(LTRIM(RTRIM(Region)))
            COLLATE Latin1_General_CI_AI = 'BOLIVAR'
            THEN 'Bolívar'

        WHEN UPPER(LTRIM(RTRIM(Region)))
            COLLATE Latin1_General_CI_AI = 'CALDAS'
            THEN 'Caldas'

        ELSE
            LTRIM(RTRIM(Region))
    END,

    -----------------------------------
    -- LIMPIEZA DIRECCIONES
    -----------------------------------
    ISNULL(
        LTRIM(RTRIM(Address)),
        'SIN DIRECCIÓN'
    ),

    -----------------------------------
    -- LIMPIEZA TELÉFONOS
    -----------------------------------
    ISNULL(
        LTRIM(RTRIM(Phone)),
        '0000000000'
    ),

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(OpeningDate AS DATE),

    IsActive

FROM DB_OLTP.dbo.Stores

ORDER BY StoreID ASC;
GO


/*SUPPLIERS*/

DELETE FROM stg_Suppliers;
GO

INSERT INTO stg_Suppliers
(
    SupplierID,
    SupplierName,
    TaxID,
    City,
    StateProvince,
    Phone,
    Email,
    IsActive
)

SELECT
    SupplierID,

    -----------------------------------
    -- LIMPIEZA NOMBRE PROVEEDOR
    -----------------------------------
    LTRIM(RTRIM(SupplierName)),

    -----------------------------------
    -- NIT LIMPIO
    -----------------------------------
    LTRIM(RTRIM(TaxID)),

    -----------------------------------
    -- ESTANDARIZACIÓN CIUDAD
    -----------------------------------
    CASE
        WHEN UPPER(LTRIM(RTRIM(City)))
            COLLATE Latin1_General_CI_AI = 'MEDELLIN'
            THEN 'Medellín'

        ELSE
            LTRIM(RTRIM(City))
    END,

    -----------------------------------
    -- ESTANDARIZACIÓN DEPARTAMENTO
    -----------------------------------
    CASE
        WHEN UPPER(LTRIM(RTRIM(StateProvince)))
            COLLATE Latin1_General_CI_AI = 'ANTIOQUIA'
            THEN 'Antioquia'

        ELSE
            LTRIM(RTRIM(StateProvince))
    END,

    -----------------------------------
    -- LIMPIEZA TELÉFONO
    -----------------------------------
    ISNULL(
        LTRIM(RTRIM(Phone)),
        '0000000000'
    ),

    -----------------------------------
    -- LIMPIEZA EMAIL
    -----------------------------------
    CASE
        WHEN Email IS NULL
            THEN 'sin_correo@correo.com'

        ELSE LOWER(LTRIM(RTRIM(Email)))
    END,

    -----------------------------------
    -- ESTADO
    -----------------------------------
    IsActive

FROM DB_OLTP.dbo.Suppliers

ORDER BY SupplierID ASC;
GO


/*SALES*/

INSERT INTO stg_Sales
(
    SaleID,
    CustomerID,
    StoreID,
    SalespersonID,
    SalesChannelID,
    CampaignID,
    SaleDate,
    PaymentMethod,
    TotalSaleAmount,
    SaleYear,
    SaleMonth
)

SELECT
    SaleID,

    CustomerID,

    StoreID,

    SalespersonID,

    SalesChannelID,

    -----------------------------------
    -- VALIDACIÓN CAMPAÑA NULA
    -----------------------------------
    ISNULL(CampaignID, 0),

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(SaleDate AS DATETIME),

    -----------------------------------
    -- NORMALIZACIÓN MÉTODO PAGO
    -----------------------------------
    CASE
        WHEN UPPER(LTRIM(RTRIM(PaymentMethod)))
            COLLATE Latin1_General_CI_AI = 'TARJETA'
            THEN 'Tarjeta'

        WHEN UPPER(LTRIM(RTRIM(PaymentMethod)))
            COLLATE Latin1_General_CI_AI = 'EFECTIVO'
            THEN 'Efectivo'

        WHEN UPPER(LTRIM(RTRIM(PaymentMethod)))
            COLLATE Latin1_General_CI_AI = 'TRANSFERENCIA'
            THEN 'Transferencia'

        ELSE 'Otro'
    END,

    -----------------------------------
    -- VALIDACIÓN TOTAL VENTA
    -----------------------------------
    CASE
        WHEN TotalSaleAmount < 0
            THEN 0

        ELSE TotalSaleAmount
    END,

    -----------------------------------
    -- CAMPOS DERIVADOS
    -----------------------------------
    YEAR(SaleDate),

    MONTH(SaleDate)

FROM DB_OLTP.dbo.Sales

ORDER BY SaleID ASC;
GO


/*SALES DETAILS*/

INSERT INTO stg_SalesDetails
(
    SaleDetailID,
    SaleID,
    ProductID,
    Quantity,
    UnitPrice,
    UnitCost,
    DiscountAmount,
    TotalAmount,
    NetAmount
)

SELECT
    SaleDetailID,

    SaleID,

    ProductID,

    -----------------------------------
    -- VALIDACIÓN CANTIDAD
    -----------------------------------
    CASE
        WHEN Quantity <= 0
            THEN 1
        ELSE Quantity
    END,

    -----------------------------------
    -- VALIDACIÓN PRECIO UNITARIO
    -----------------------------------
    CASE
        WHEN UnitPrice < 0
            THEN 0
        ELSE UnitPrice
    END,

    -----------------------------------
    -- VALIDACIÓN COSTO UNITARIO
    -----------------------------------
    CASE
        WHEN UnitCost < 0
            THEN 0
        ELSE UnitCost
    END,

    -----------------------------------
    -- VALIDACIÓN DESCUENTO
    -----------------------------------
    CASE
        WHEN DiscountAmount IS NULL
            THEN 0

        WHEN DiscountAmount < 0
            THEN 0

        ELSE DiscountAmount
    END,

    -----------------------------------
    -- VALIDACIÓN TOTAL
    -----------------------------------
    CASE
        WHEN TotalAmount < 0
            THEN 0

        ELSE TotalAmount
    END,

    -----------------------------------
    -- CAMPO DERIVADO
    -- TOTAL NETO
    -----------------------------------
    (
        (Quantity * UnitPrice)
        -
        ISNULL(DiscountAmount,0)
    )

FROM DB_OLTP.dbo.SalesDetails

ORDER BY SaleDetailID ASC;
GO


/*DAILY INVENTORY*/

INSERT INTO stg_DailyInventory
(
    InventoryID,
    ProductID,
    StoreID,
    InventoryDate,
    InitialStock,
    StockIn,
    StockOut,
    FinalStock
)

SELECT
    InventoryID,

    ProductID,

    StoreID,

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(InventoryDate AS DATE),

    -----------------------------------
    -- VALIDACIÓN STOCK INICIAL
    -----------------------------------
    CASE
        WHEN InitialStock < 0
            THEN 0
        ELSE InitialStock
    END,

    -----------------------------------
    -- VALIDACIÓN ENTRADAS
    -----------------------------------
    CASE
        WHEN StockIn < 0
            THEN 0
        ELSE StockIn
    END,

    -----------------------------------
    -- VALIDACIÓN SALIDAS
    -----------------------------------
    CASE
        WHEN StockOut < 0
            THEN 0
        ELSE StockOut
    END,

    -----------------------------------
    -- RECÁLCULO INVENTARIO FINAL
    -----------------------------------
    (
        CASE
            WHEN InitialStock < 0
                THEN 0
            ELSE InitialStock
        END

        +

        CASE
            WHEN StockIn < 0
                THEN 0
            ELSE StockIn
        END

        -

        CASE
            WHEN StockOut < 0
                THEN 0
            ELSE StockOut
        END
    )

FROM DB_OLTP.dbo.DailyInventory

ORDER BY InventoryID ASC;
GO


/*SALES CHANNELS*/

WITH CleanChannels AS
(
    SELECT
        SalesChannelID,

        -----------------------------------
        -- NORMALIZACIÓN CANALES
        -----------------------------------
        CASE
            WHEN UPPER(LTRIM(RTRIM(ChannelName)))
                COLLATE Latin1_General_CI_AI
                = 'TIENDA FISICA'
                THEN 'Tienda Física'

            WHEN UPPER(LTRIM(RTRIM(ChannelName)))
                COLLATE Latin1_General_CI_AI
                = 'PAGINA WEB'
                THEN 'Página Web'

            WHEN UPPER(LTRIM(RTRIM(ChannelName)))
                COLLATE Latin1_General_CI_AI
                = 'APLICACION MOVIL'
                THEN 'Aplicación Móvil'

            WHEN UPPER(LTRIM(RTRIM(ChannelName)))
                COLLATE Latin1_General_CI_AI
                = 'MARKETPLACE'
                THEN 'Marketplace'

            ELSE
                LTRIM(RTRIM(ChannelName))
        END AS CleanChannelName,

        -----------------------------------
        -- DETECCIÓN DUPLICADOS
        -----------------------------------
        ROW_NUMBER() OVER
        (
            PARTITION BY
            UPPER(LTRIM(RTRIM(ChannelName)))
            COLLATE Latin1_General_CI_AI

            ORDER BY SalesChannelID
        ) AS rn

    FROM DB_OLTP.dbo.SalesChannels
)

INSERT INTO stg_SalesChannels
(
    SalesChannelID,
    ChannelName
)

SELECT
    SalesChannelID,

    CleanChannelName

FROM CleanChannels

WHERE rn = 1

ORDER BY SalesChannelID ASC;
GO


/*CAMPAIGNS*/

INSERT INTO stg_Campaigns
(
    CampaignID,
    CampaignName,
    StartDate,
    EndDate,
    DiscountPercentage,
    CampaignDurationDays
)

SELECT
    CampaignID,

    -----------------------------------
    -- LIMPIEZA NOMBRE CAMPAÑA
    -----------------------------------
    LTRIM(RTRIM(CampaignName)),

    -----------------------------------
    -- CONVERSIÓN FECHA INICIO
    -----------------------------------
    CAST(StartDate AS DATE),

    -----------------------------------
    -- CONVERSIÓN FECHA FIN
    -----------------------------------
    CAST(EndDate AS DATE),

    -----------------------------------
    -- VALIDACIÓN DESCUENTO
    -----------------------------------
    CASE
        WHEN DiscountPercentage < 0
            THEN 0

        WHEN DiscountPercentage > 100
            THEN 100

        ELSE DiscountPercentage
    END,

    -----------------------------------
    -- CAMPO DERIVADO
    -- DURACIÓN CAMPAÑA
    -----------------------------------
    DATEDIFF(DAY, StartDate, EndDate)

FROM DB_OLTP.dbo.Campaigns

WHERE EndDate >= StartDate

ORDER BY CampaignID ASC;
GO


/*SALESPERSONS*/

INSERT INTO stg_Salespersons
(
    SalespersonID,
    StoreID,
    FullName,
    DocumentNumber,
    Email,
    HireDate,
    Salary,
    IsActive
)

SELECT
    SP.SalespersonID,

    -----------------------------------
    -- VALIDACIÓN STORE EXISTENTE
    -----------------------------------
    SP.StoreID,

    -----------------------------------
    -- LIMPIEZA NOMBRE
    -----------------------------------
    LTRIM(RTRIM(SP.FullName)),

    -----------------------------------
    -- LIMPIEZA DOCUMENTO
    -----------------------------------
    LTRIM(RTRIM(SP.DocumentNumber)),

    -----------------------------------
    -- LIMPIEZA EMAIL
    -----------------------------------
    CASE
        WHEN SP.Email IS NULL
            THEN CONCAT(
                    'sin_correo_',
                    SP.SalespersonID,
                    '@empresa.com'
                 )

        ELSE LOWER(LTRIM(RTRIM(SP.Email)))
    END,

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(SP.HireDate AS DATE),

    -----------------------------------
    -- VALIDACIÓN SALARIO
    -----------------------------------
    CASE
        WHEN SP.Salary <= 0
            THEN 1000000

        ELSE SP.Salary
    END,

    SP.IsActive

FROM DB_OLTP.dbo.Salespersons SP

INNER JOIN DB_OLTP.dbo.Stores ST
    ON SP.StoreID = ST.StoreID

ORDER BY SP.SalespersonID ASC;
GO


/*PURCHASES*/

INSERT INTO stg_Purchases
(
    PurchaseID,
    SupplierID,
    StoreID,
    PurchaseDate,
    TotalPurchaseAmount,
    PurchaseYear,
    PurchaseMonth
)

SELECT
    P.PurchaseID,

    -----------------------------------
    -- VALIDACIÓN SUPPLIER EXISTENTE
    -----------------------------------
    P.SupplierID,

    -----------------------------------
    -- VALIDACIÓN STORE EXISTENTE
    -----------------------------------
    P.StoreID,

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(P.PurchaseDate AS DATE),

    -----------------------------------
    -- VALIDACIÓN MONTO TOTAL
    -----------------------------------
    CASE
        WHEN P.TotalPurchaseAmount <= 0
            THEN 0

        ELSE P.TotalPurchaseAmount
    END,

    -----------------------------------
    -- CAMPO DERIVADO AÑO
    -----------------------------------
    YEAR(P.PurchaseDate),

    -----------------------------------
    -- CAMPO DERIVADO MES
    -----------------------------------
    MONTH(P.PurchaseDate)

FROM DB_OLTP.dbo.Purchases P

INNER JOIN DB_OLTP.dbo.Suppliers SU
    ON P.SupplierID = SU.SupplierID

INNER JOIN DB_OLTP.dbo.Stores ST
    ON P.StoreID = ST.StoreID

ORDER BY P.PurchaseID ASC;
GO

/*PURCHASE DETAILS*/

INSERT INTO stg_PurchaseDetails
(
    PurchaseDetailID,
    PurchaseID,
    ProductID,
    Quantity,
    UnitCost,
    TotalAmount,
    AverageCost
)

SELECT
    PD.PurchaseDetailID,

    -----------------------------------
    -- VALIDACIÓN PURCHASE EXISTENTE
    -----------------------------------
    PD.PurchaseID,

    -----------------------------------
    -- VALIDACIÓN PRODUCT EXISTENTE
    -----------------------------------
    PD.ProductID,

    -----------------------------------
    -- VALIDACIÓN CANTIDAD
    -----------------------------------
    CASE
        WHEN PD.Quantity <= 0
            THEN 1

        ELSE PD.Quantity
    END,

    -----------------------------------
    -- VALIDACIÓN COSTO UNITARIO
    -----------------------------------
    CASE
        WHEN PD.UnitCost <= 0
            THEN 0

        ELSE PD.UnitCost
    END,

    -----------------------------------
    -- RECÁLCULO TOTAL
    -----------------------------------
    (
        CASE
            WHEN PD.Quantity <= 0
                THEN 1
            ELSE PD.Quantity
        END
    )
    *
    (
        CASE
            WHEN PD.UnitCost <= 0
                THEN 0
            ELSE PD.UnitCost
        END
    ),

    -----------------------------------
    -- CAMPO DERIVADO
    -- COSTO PROMEDIO
    -----------------------------------
    CASE
        WHEN PD.Quantity <= 0
            THEN 0

        ELSE PD.TotalAmount / PD.Quantity
    END

FROM DB_OLTP.dbo.PurchaseDetails PD

INNER JOIN DB_OLTP.dbo.Purchases P
    ON PD.PurchaseID = P.PurchaseID

INNER JOIN DB_OLTP.dbo.Products PR
    ON PD.ProductID = PR.ProductID

ORDER BY PD.PurchaseDetailID ASC;
GO


/*RETURNS*/

INSERT INTO stg_Returns
(
    ReturnID,
    SaleID,
    ProductID,
    ReturnDate,
    Quantity,
    ReturnReason,
    RefundAmount
)

SELECT
    R.ReturnID,

    -----------------------------------
    -- VALIDACIÓN SALE EXISTENTE
    -----------------------------------
    R.SaleID,

    -----------------------------------
    -- VALIDACIÓN PRODUCT EXISTENTE
    -----------------------------------
    R.ProductID,

    -----------------------------------
    -- CONVERSIÓN FECHA
    -----------------------------------
    CAST(R.ReturnDate AS DATE),

    -----------------------------------
    -- VALIDACIÓN CANTIDAD
    -----------------------------------
    CASE
        WHEN R.Quantity <= 0
            THEN 1

        ELSE R.Quantity
    END,

    -----------------------------------
    -- NORMALIZACIÓN MOTIVO DEVOLUCIÓN
    -----------------------------------
    CASE

        WHEN UPPER(LTRIM(RTRIM(R.ReturnReason)))
             COLLATE Latin1_General_CI_AI
             = 'PRODUCTO DEFECTUOSO'
            THEN 'Producto Defectuoso'

        WHEN UPPER(LTRIM(RTRIM(R.ReturnReason)))
             COLLATE Latin1_General_CI_AI
             = 'ERROR EN TALLA'
            THEN 'Error en Talla'

        WHEN UPPER(LTRIM(RTRIM(R.ReturnReason)))
             COLLATE Latin1_General_CI_AI
             = 'ENTREGA TARDIA'
            THEN 'Entrega Tardía'

        WHEN UPPER(LTRIM(RTRIM(R.ReturnReason)))
             COLLATE Latin1_General_CI_AI
             = 'NO CUMPLIO EXPECTATIVAS'
            THEN 'No Cumplió Expectativas'

        ELSE 'Otro'
    END,

    -----------------------------------
    -- VALIDACIÓN MONTO DEVOLUCIÓN
    -----------------------------------
    CASE
        WHEN R.RefundAmount < 0
            THEN 0

        ELSE R.RefundAmount
    END

FROM DB_OLTP.dbo.Returns R

INNER JOIN DB_OLTP.dbo.Sales S
    ON R.SaleID = S.SaleID

INNER JOIN DB_OLTP.dbo.Products P
    ON R.ProductID = P.ProductID

ORDER BY R.ReturnID ASC;
GO


/*SALES TARGETS*/

DELETE FROM stg_SalesTargets;
GO

WITH Targets AS
(
    SELECT
        ST.TargetID,
        ST.StoreID,
        ST.CategoryID,
        ST.YearNumber,
        ST.MonthNumber,
        ST.TargetAmount,

        -----------------------------------
        -- DISTRIBUCIÓN EQUITATIVA
        -- 1200 / 20 = 60
        -----------------------------------
        ROW_NUMBER() OVER (ORDER BY ST.TargetID) AS rn

    FROM DB_OLTP.dbo.SalesTargets ST
),

AssignedTargets AS
(
    SELECT
        T.TargetID,
        T.StoreID,
        T.CategoryID,

        -----------------------------------
        -- ASIGNACIÓN EXACTA:
        -- 60 REGISTROS POR VENDEDOR
        -----------------------------------
        ((T.rn - 1) / 60) + 1 AS SalespersonID,

        T.YearNumber,
        T.MonthNumber,
        T.TargetAmount

    FROM Targets T
)

INSERT INTO stg_SalesTargets
(
    TargetID,
    StoreID,
    CategoryID,
    SalespersonID,
    YearNumber,
    MonthNumber,
    TargetAmount,
    QuarterlyTarget
)

SELECT
    AT.TargetID,

    -----------------------------------
    -- VALIDACIÓN STORE
    -----------------------------------
    AT.StoreID,

    -----------------------------------
    -- VALIDACIÓN CATEGORY
    -----------------------------------
    AT.CategoryID,

    -----------------------------------
    -- VENDEDOR ASIGNADO
    -----------------------------------
    SP.SalespersonID,

    -----------------------------------
    -- VALIDACIÓN AÑO
    -----------------------------------
    CASE
        WHEN AT.YearNumber < 2020
            THEN 2025
        ELSE AT.YearNumber
    END,

    -----------------------------------
    -- VALIDACIÓN MES
    -----------------------------------
    CASE
        WHEN AT.MonthNumber < 1
             OR AT.MonthNumber > 12
            THEN 1
        ELSE AT.MonthNumber
    END,

    -----------------------------------
    -- VALIDACIÓN META
    -----------------------------------
    CASE
        WHEN AT.TargetAmount <= 0
            THEN 0
        ELSE AT.TargetAmount
    END,

    -----------------------------------
    -- CAMPO DERIVADO:
    -- TRIMESTRE
    -----------------------------------
    CASE
        WHEN AT.MonthNumber BETWEEN 1 AND 3
            THEN 'Q1'

        WHEN AT.MonthNumber BETWEEN 4 AND 6
            THEN 'Q2'

        WHEN AT.MonthNumber BETWEEN 7 AND 9
            THEN 'Q3'

        ELSE 'Q4'
    END

FROM AssignedTargets AT

INNER JOIN DB_OLTP.dbo.Salespersons SP
    ON AT.SalespersonID = SP.SalespersonID

ORDER BY AT.TargetID ASC;
GO
