USE DB_DW;
GO

-- Relaciones de FactSales
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimSalesperson FOREIGN KEY (SalespersonKey) REFERENCES DimSalesperson(SalespersonKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimSalesChannel FOREIGN KEY (ChannelKey) REFERENCES DimSalesChannel(ChannelKey);
ALTER TABLE FactSales ADD CONSTRAINT FK_FactSales_DimCampaign FOREIGN KEY (CampaignKey) REFERENCES DimCampaign(CampaignKey);

-- Relaciones de FactInventory
ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey);
ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
ALTER TABLE FactInventory ADD CONSTRAINT FK_FactInventory_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);

-- Relaciones de FactSalesTargets
ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey);
ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimSalesperson FOREIGN KEY (SalespersonKey) REFERENCES DimSalesperson(SalespersonKey);
ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimCategory FOREIGN KEY (CategoryKey) REFERENCES DimCategory(CategoryKey);
ALTER TABLE FactSalesTargets ADD CONSTRAINT FK_FactTargets_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);