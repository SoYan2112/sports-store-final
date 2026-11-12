-- =============================================================================
-- Sports Store Backend - Microservices Database Initialization & Seeding Script
-- MSSQL 2022 Init Script for Docker Compose 1-Command Startup
-- =============================================================================

USE master;
GO

-- 1. Create Databases for Microservices if not exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'sports_store')
BEGIN
    CREATE DATABASE [sports_store];
    PRINT 'Database [sports_store] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [sports_store] already exists.';
END
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'sports_store_product')
BEGIN
    CREATE DATABASE [sports_store_product];
    PRINT 'Database [sports_store_product] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [sports_store_product] already exists.';
END
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'sports_store_order')
BEGIN
    CREATE DATABASE [sports_store_order];
    PRINT 'Database [sports_store_order] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [sports_store_order] already exists.';
END
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'sports_store_voucher')
BEGIN
    CREATE DATABASE [sports_store_voucher];
    PRINT 'Database [sports_store_voucher] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [sports_store_voucher] already exists.';
END
GO

-- =============================================================================
-- 2. Seed Data for IdentityService (sports_store)
-- =============================================================================
USE [sports_store];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'email')
BEGIN
    CREATE TABLE email (
        email_id NVARCHAR(36) PRIMARY KEY,
        address NVARCHAR(255) NOT NULL UNIQUE,
        is_verified BIT NOT NULL DEFAULT 1,
        code NVARCHAR(150),
        verified_at BIGINT,
        created_at BIGINT
    );
    PRINT 'Table [email] created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'customer')
BEGIN
    CREATE TABLE customer (
        user_id NVARCHAR(36) PRIMARY KEY,
        username NVARCHAR(255) UNIQUE,
        password NVARCHAR(255),
        full_name NVARCHAR(255),
        phone_number NVARCHAR(50),
        status NVARCHAR(50),
        token NVARCHAR(550),
        gender BIT,
        email_id NVARCHAR(36) REFERENCES email(email_id),
        created_at BIGINT
    );
    PRINT 'Table [customer] created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'shipping_address')
BEGIN
    CREATE TABLE shipping_address (
        id NVARCHAR(36) PRIMARY KEY,
        title NVARCHAR(255),
        street NVARCHAR(255),
        ward NVARCHAR(255),
        province NVARCHAR(255),
        country NVARCHAR(255),
        created_at BIGINT NOT NULL,
        is_default BIT NOT NULL,
        user_id NVARCHAR(36) NOT NULL REFERENCES customer(user_id)
    );
    PRINT 'Table [shipping_address] created.';
END
GO

-- Insert default test accounts (password: 123456 -> MD5: e10adc3949ba59abbe56e057f20f883e)
IF NOT EXISTS (SELECT 1 FROM email WHERE email_id = 'em_01')
BEGIN
    INSERT INTO email (email_id, address, is_verified, created_at)
    VALUES ('em_01', 'a@gmail.com', 1, 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM email WHERE email_id = 'em_02')
BEGIN
    INSERT INTO email (email_id, address, is_verified, created_at)
    VALUES ('em_02', 'b@gmail.com', 1, 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM customer WHERE user_id = 'user_01')
BEGIN
    INSERT INTO customer (user_id, username, password, full_name, phone_number, status, gender, email_id, created_at)
    VALUES ('user_01', 'a@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', N'Nguyễn Văn A', '0901234567', 'ACTIVE', 1, 'em_01', 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM customer WHERE user_id = 'user_02')
BEGIN
    INSERT INTO customer (user_id, username, password, full_name, phone_number, status, gender, email_id, created_at)
    VALUES ('user_02', 'b@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', N'Nguyễn Văn B', '0912345678', 'ACTIVE', 1, 'em_02', 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM shipping_address WHERE id = 'addr_01')
BEGIN
    INSERT INTO shipping_address (id, title, street, ward, province, country, created_at, is_default, user_id)
    VALUES ('addr_01', N'Nhà riêng', N'Số 123 Đường Nguyễn Huệ', N'Phường Bến Nghé', N'TP. Hồ Chí Minh', N'Việt Nam', 1731300000000, 1, 'user_01');
END

IF NOT EXISTS (SELECT 1 FROM shipping_address WHERE id = 'addr_02')
BEGIN
    INSERT INTO shipping_address (id, title, street, ward, province, country, created_at, is_default, user_id)
    VALUES ('addr_02', N'Công ty', N'Khu Công nghệ cao', N'Phường Tân Phú', N'TP. Thủ Đức', N'Việt Nam', 1731300000000, 0, 'user_01');
END
GO

-- =============================================================================
-- 3. Seed Data for VoucherService (sports_store_voucher)
-- =============================================================================
USE [sports_store_voucher];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'vouchers')
BEGIN
    CREATE TABLE vouchers (
        voucher_id NVARCHAR(64) PRIMARY KEY,
        code NVARCHAR(50) NOT NULL UNIQUE,
        title NVARCHAR(255) NOT NULL,
        description NVARCHAR(500),
        type NVARCHAR(50) NOT NULL,
        discount_value DECIMAL(18, 2) NOT NULL,
        min_order_value DECIMAL(18, 2) NOT NULL,
        max_discount_amount DECIMAL(18, 2),
        start_date DATETIME2 NOT NULL,
        end_date DATETIME2 NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at BIGINT,
        updated_at BIGINT
    );
    PRINT 'Table [vouchers] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'FREESHIP')
BEGIN
    INSERT INTO vouchers (voucher_id, code, title, description, type, discount_value, min_order_value, max_discount_amount, start_date, end_date, is_active, created_at, updated_at)
    VALUES ('vch_01', 'FREESHIP', N'Miễn phí vận chuyển toàn quốc', N'Giảm 30.000 ₫ phí ship cho đơn từ 500.000 ₫', 'FREE_SHIPPING', 30000.00, 500000.00, 30000.00, DATEADD(day, -5, GETDATE()), DATEADD(day, 60, GETDATE()), 1, 1731300000000, 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'SPORT20')
BEGIN
    INSERT INTO vouchers (voucher_id, code, title, description, type, discount_value, min_order_value, max_discount_amount, start_date, end_date, is_active, created_at, updated_at)
    VALUES ('vch_02', 'SPORT20', N'Giảm 20% cho đơn hàng thể thao', N'Giảm 20% tối đa 150.000 ₫ cho toàn bộ đơn hàng', 'PERCENTAGE', 20.00, 1000000.00, 150000.00, DATEADD(day, -5, GETDATE()), DATEADD(day, 60, GETDATE()), 1, 1731300000000, 1731300000000);
END

IF NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'WELCOME50')
BEGIN
    INSERT INTO vouchers (voucher_id, code, title, description, type, discount_value, min_order_value, max_discount_amount, start_date, end_date, is_active, created_at, updated_at)
    VALUES ('vch_03', 'WELCOME50', N'Chào bạn mới giảm ngay 50.000 ₫', N'Dành riêng cho khách hàng đăng ký mới', 'FIXED_AMOUNT', 50000.00, 300000.00, 50000.00, DATEADD(day, -5, GETDATE()), DATEADD(day, 60, GETDATE()), 1, 1731300000000, 1731300000000);
END
GO

PRINT '=================================================================';
PRINT 'Sports Store Database Initialization & Seeding completed successfully!';
PRINT '=================================================================';
GO
