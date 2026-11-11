-- FUCarRentingSystem seed data - MSS301 Assignment 01
-- Database-per-service: each microservice owns its own database.
-- Run this script in SQL Server BEFORE testing. One script, two databases:
--   FUCarRenting_CarDB      -> owned by car-service
--   FUCarRenting_RentingDB  -> owned by renting-service
-- There is NO foreign key between the two databases: Renting.CarId only
-- references Car.CarId logically, and is resolved via OpenFeign at runtime.

-- ============================================================
-- Database 1: FUCarRenting_CarDB  (car-service)
-- ============================================================
USE master;
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FUCarRenting_CarDB')
BEGIN
    ALTER DATABASE FUCarRenting_CarDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FUCarRenting_CarDB;
END
GO

CREATE DATABASE FUCarRenting_CarDB;
GO

USE FUCarRenting_CarDB;
GO

CREATE TABLE dbo.Car (
    CarId       INT IDENTITY(1,1) PRIMARY KEY,
    CarName     NVARCHAR(100)  NOT NULL UNIQUE,
    Model       NVARCHAR(100)  NOT NULL,
    Color       NVARCHAR(50)   NOT NULL,
    PricePerDay DECIMAL(12, 0) NOT NULL,
    Status      NVARCHAR(20)   NOT NULL CHECK (Status IN ('Available', 'Rented'))
);
GO

-- 5 service cars: ids 1, 2, 4 Available; ids 3, 5 Rented
SET IDENTITY_INSERT dbo.Car ON;
INSERT INTO dbo.Car (CarId, CarName, Model, Color, PricePerDay, Status) VALUES
    (1, N'Toyota Camry',  N'Camry 2.5Q', N'White', 1500000, 'Available'),
    (2, N'Lexus LX570', N'LX570', N'Black',  3000000, 'Available'),
    (3, N'Mazda CX-8',    N'CX-8 Luxury', N'Silver', 1200000, 'Rented'),
    (4, N'Hyundai Tucson', N'Tucson 2.0', N'Blue', 1300000, 'Available'),
    (5, N'Mercedes E-Class', N'E300 AMG', N'Grey',    3500000, 'Rented');
SET IDENTITY_INSERT dbo.Car OFF;
GO

-- ============================================================
-- Database 2: FUCarRenting_RentingDB  (renting-service)
-- ============================================================
USE master;
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FUCarRenting_RentingDB')
BEGIN
    ALTER DATABASE FUCarRenting_RentingDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FUCarRenting_RentingDB;
END
GO

CREATE DATABASE FUCarRenting_RentingDB;
GO

USE FUCarRenting_RentingDB;
GO

-- CarId is a plain int: no cross-database foreign key (database-per-service).
CREATE TABLE dbo.Renting (
    RentingId  INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId NVARCHAR(20) NOT NULL,
    CarId      INT NOT NULL,
    StartDate  DATE NOT NULL,
    EndDate    DATE NOT NULL,
    TotalPrice DECIMAL(12, 0) NOT NULL
);
GO

-- 2 history transactions (CarId references FUCarRenting_CarDB.dbo.Car logically)
SET IDENTITY_INSERT dbo.Renting ON;
INSERT INTO dbo.Renting (RentingId, CustomerId, CarId, StartDate, EndDate, TotalPrice) VALUES
    (1, N'CUST-001', 3, '2026-10-01', '2026-10-05', 6000000),
    (2, N'CUST-002', 5, '2026-10-06', '2026-10-08', 10500000);
SET IDENTITY_INSERT dbo.Renting OFF;
GO

-- Test walkthrough expectations (with seed above, creating a renting via gateway):
--   carId = 2, 2026-10-15 .. 2026-10-17 -> 201, total = 6,000,000, car 2 becomes Rented
--   carId = 3 -> 409 (already Rented)
--   carId = 99 -> 404
--   carId = 2 again after success -> 409 (car no longer Available)
--   EndDate <= StartDate -> 400
--   blank customerId -> 400
