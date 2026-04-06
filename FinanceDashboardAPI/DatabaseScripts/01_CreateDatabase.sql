-- =========================================
-- Finance Dashboard API - Database Schema
-- ======================================

-- =========================================
-- 1. CREATE DATABASE
-- =========================================
CREATE DATABASE FinanceDashboardDB;
GO

USE FinanceDashboardDB;
GO

-- =========================================
-- 2. USERS TABLE
-- =========================================
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Admin', 'Analyst', 'Viewer')),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NULL
);
GO

-- =========================================
-- 3. FINANCIAL RECORDS TABLE
-- =========================================
CREATE TABLE FinancialRecords (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    Type NVARCHAR(10) NOT NULL CHECK (Type IN ('Income', 'Expense')),
    Category NVARCHAR(100) NOT NULL,
    Date DATETIME2 NOT NULL,
    Notes NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    DeletedAt DATETIME2 NULL,
    CONSTRAINT FK_FinancialRecords_Users 
        FOREIGN KEY (UserId) 
        REFERENCES Users(Id) 
        ON DELETE CASCADE
);
GO

-- =========================================
-- 4. INDEXES FOR PERFORMANCE
-- =========================================
-- Index on UserId for faster lookups
CREATE NONCLUSTERED INDEX IX_FinancialRecords_UserId 
    ON FinancialRecords(UserId);

-- Composite index for user records sorted by date
CREATE NONCLUSTERED INDEX IX_FinancialRecords_UserId_Date 
    ON FinancialRecords(UserId, Date DESC);

-- Index on IsDeleted for soft delete queries
CREATE NONCLUSTERED INDEX IX_FinancialRecords_IsDeleted 
    ON FinancialRecords(IsDeleted) 
    WHERE IsDeleted = 0;

-- Index on Username for login queries
CREATE NONCLUSTERED INDEX IX_Users_Username 
    ON Users(Username);
GO

-- =========================================
-- 5. VERIFICATION QUERIES
-- =========================================
-- Verify tables created
SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_TYPE = 'BASE TABLE'
ORDER BY 
    TABLE_NAME;
GO

-- Verify indexes created
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM 
    sys.indexes i
INNER JOIN 
    sys.tables t ON i.object_id = t.object_id
WHERE 
    t.name IN ('Users', 'FinancialRecords')
    AND i.name IS NOT NULL
ORDER BY 
    t.name, i.name;
GO

-- =========================================
-- NOTES:
-- =========================================
-- 1. This script is for REFERENCE only
-- 2. The project uses Entity Framework Core Code-First approach
-- 3. Database is created automatically via migrations
-- 4. To create database, run: dotnet ef database update
-- 5. Migration files are in: Migrations/ folder
-- =========================================
