USE DB_DW;
GO

CREATE TABLE ETL_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProcessName VARCHAR(100) NOT NULL,      -- Nombre del proceso (ej: 'CargarDimCustomer')
    StartDate DATETIME NOT NULL,             -- Fecha y hora de inicio
    EndDate DATETIME NULL,                   -- Fecha y hora de fin
    Status VARCHAR(20) NOT NULL,             -- 'Success', 'Failed', 'In Progress'
    RowsRead INT DEFAULT 0,                  -- Registros leídos desde staging
    RowsLoaded INT DEFAULT 0,                -- Registros cargados en DW
    RowsRejected INT DEFAULT 0,              -- Registros rechazados
    ErrorMessage NVARCHAR(MAX) NULL,         -- Mensaje de error si falló
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO