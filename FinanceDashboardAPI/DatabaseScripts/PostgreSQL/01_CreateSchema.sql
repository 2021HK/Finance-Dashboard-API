-- =====================================================
-- Finance Dashboard Database Schema
-- PostgreSQL 16+
-- Database-First Approach
-- =====================================================

-- Drop tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS "FinancialRecords" CASCADE;
DROP TABLE IF EXISTS "Users" CASCADE;

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE "Users" (
    "Id" SERIAL PRIMARY KEY,
    "Username" VARCHAR(255) NOT NULL,
    "PasswordHash" TEXT NOT NULL,
    "Role" VARCHAR(50) NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITHOUT TIME ZONE
);

-- Unique constraint on Username
CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username");

-- Index for active users lookup
CREATE INDEX "IX_Users_IsActive" ON "Users" ("IsActive");

-- Index for role-based queries
CREATE INDEX "IX_Users_Role" ON "Users" ("Role");

COMMENT ON TABLE "Users" IS 'Stores user accounts with authentication and role information';
COMMENT ON COLUMN "Users"."Role" IS 'User role: Admin, Analyst, or Viewer';
COMMENT ON COLUMN "Users"."PasswordHash" IS 'BCrypt hashed password - never store plain text';

-- =====================================================
-- FINANCIAL RECORDS TABLE
-- =====================================================
CREATE TABLE "FinancialRecords" (
    "Id" SERIAL PRIMARY KEY,
    "UserId" INTEGER NOT NULL,
    "Amount" NUMERIC(18, 2) NOT NULL,
    "Type" VARCHAR(10) NOT NULL,
    "Category" VARCHAR(100) NOT NULL,
    "Date" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "Notes" VARCHAR(500),
    "IsDeleted" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITHOUT TIME ZONE,
    "DeletedAt" TIMESTAMP WITHOUT TIME ZONE,
    
    -- Foreign key constraint
    CONSTRAINT "FK_FinancialRecords_Users_UserId" 
        FOREIGN KEY ("UserId") 
        REFERENCES "Users" ("Id") 
        ON DELETE CASCADE
);

-- Check constraint for transaction type
ALTER TABLE "FinancialRecords" 
ADD CONSTRAINT "CK_FinancialRecords_Type" 
CHECK ("Type" IN ('Income', 'Expense'));

-- Check constraint for positive amounts
ALTER TABLE "FinancialRecords" 
ADD CONSTRAINT "CK_FinancialRecords_Amount" 
CHECK ("Amount" > 0);

-- Indexes for performance
CREATE INDEX "IX_FinancialRecords_UserId" ON "FinancialRecords" ("UserId");
CREATE INDEX "IX_FinancialRecords_Date" ON "FinancialRecords" ("Date" DESC);
CREATE INDEX "IX_FinancialRecords_IsDeleted" ON "FinancialRecords" ("IsDeleted");
CREATE INDEX "IX_FinancialRecords_Type" ON "FinancialRecords" ("Type");
CREATE INDEX "IX_FinancialRecords_UserId_IsDeleted" ON "FinancialRecords" ("UserId", "IsDeleted");

COMMENT ON TABLE "FinancialRecords" IS 'Stores income and expense transactions';
COMMENT ON COLUMN "FinancialRecords"."Type" IS 'Transaction type: Income or Expense';
COMMENT ON COLUMN "FinancialRecords"."IsDeleted" IS 'Soft delete flag - records are not physically deleted';

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('Users', 'FinancialRecords');

-- Verify foreign keys
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name IN ('FinancialRecords');

-- Show table structure
\d "Users"
\d "FinancialRecords"
