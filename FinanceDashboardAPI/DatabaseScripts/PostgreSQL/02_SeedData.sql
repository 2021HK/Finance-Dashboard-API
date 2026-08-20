-- =====================================================
-- Finance Dashboard Seed Data
-- PostgreSQL
-- Sample users and financial records for testing
-- =====================================================

-- =====================================================
-- CLEAN SLATE (Optional - Uncomment to reset data)
-- =====================================================
-- WARNING: This will delete ALL existing data
-- Uncomment the lines below to start fresh on each run

-- DELETE FROM "FinancialRecords";
-- DELETE FROM "Users";
-- ALTER SEQUENCE "Users_Id_seq" RESTART WITH 1;
-- ALTER SEQUENCE "FinancialRecords_Id_seq" RESTART WITH 1;

-- =====================================================
-- SEED USERS
-- =====================================================
-- Note: All passwords are hashed using BCrypt (Cost: 11)
-- Plain text passwords for reference (DO NOT USE IN PRODUCTION):
-- admin         -> Admin@123
-- analyst       -> Analyst@123
-- viewer        -> Viewer@123
-- testuser      -> Test@123
-- inactive_user -> Inactive@123

-- Insert users with idempotency (won't fail on duplicate runs)
INSERT INTO "Users" ("Username", "PasswordHash", "Role", "IsActive", "CreatedAt")
VALUES 
    -- Admin user (Password: Admin@123)
    -- Hash verified: $2a$11$nyuG87MahlYXOsRJgAI2d.HL09SAyQ3gptg.3iP1Al2DSjn91anWe
    ('admin', '$2a$11$nyuG87MahlYXOsRJgAI2d.HL09SAyQ3gptg.3iP1Al2DSjn91anWe', 'Admin', TRUE, CURRENT_TIMESTAMP),
    
    -- Analyst user (Password: Analyst@123)
    -- Hash verified: $2a$11$/BgYjMsmY.1v4Kolt6n6..3kw2fdGrfhK0fzumHcGKGIdNpS9nB0.
    ('analyst', '$2a$11$/BgYjMsmY.1v4Kolt6n6..3kw2fdGrfhK0fzumHcGKGIdNpS9nB0.', 'Analyst', TRUE, CURRENT_TIMESTAMP),
    
    -- Viewer user (Password: Viewer@123)
    -- Hash verified: $2a$11$mjZ6Hn0VuNlwyoSmgZIEhuGZ37eR7g2WGw0Ry5.laQN0mXoyWACQ.
    ('viewer', '$2a$11$mjZ6Hn0VuNlwyoSmgZIEhuGZ37eR7g2WGw0Ry5.laQN0mXoyWACQ.', 'Viewer', TRUE, CURRENT_TIMESTAMP),
    
    -- Additional test user (Password: Test@123)
    -- Hash verified: $2a$11$4ZmZai7ydL8poieZqd6XK.wR2qv8eoy1Phlv1fPU/jA3N/tvSX.1G
    ('testuser', '$2a$11$4ZmZai7ydL8poieZqd6XK.wR2qv8eoy1Phlv1fPU/jA3N/tvSX.1G', 'Analyst', TRUE, CURRENT_TIMESTAMP),
    
    -- Inactive user for testing (Password: Inactive@123)
    -- Hash verified: $2a$11$8eUYQqAYviwazTMb5plCfeibus5/qERFfk21IiqrDhKBjdqHqdH..
    ('inactive_user', '$2a$11$8eUYQqAYviwazTMb5plCfeibus5/qERFfk21IiqrDhKBjdqHqdH..', 'Viewer', FALSE, CURRENT_TIMESTAMP)
ON CONFLICT ("Username") DO NOTHING;

-- =====================================================
-- SEED FINANCIAL RECORDS
-- =====================================================
-- Sample income and expense records
-- Uses dynamic UserId lookup to work even if user IDs change

-- Admin's records
INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 5000.00, 'Income', 'Salary', '2026-08-01 09:00:00', 'Monthly salary payment', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 1200.00, 'Income', 'Bonus', '2026-08-05 14:30:00', 'Performance bonus Q3', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 150.75, 'Expense', 'Groceries', '2026-08-02 18:15:00', 'Weekly grocery shopping', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 89.99, 'Expense', 'Utilities', '2026-08-03 10:00:00', 'Electric bill payment', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 500.00, 'Expense', 'Rent', '2026-08-01 08:00:00', 'Monthly rent payment', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 45.50, 'Expense', 'Entertainment', '2026-08-07 20:00:00', 'Movie tickets and dinner', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

-- Analyst's records
INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 4500.00, 'Income', 'Salary', '2026-08-01 09:00:00', 'Monthly salary', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 300.00, 'Income', 'Freelance', '2026-08-10 16:00:00', 'Freelance project payment', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 120.00, 'Expense', 'Groceries', '2026-08-03 17:00:00', 'Grocery shopping', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 65.00, 'Expense', 'Utilities', '2026-08-04 11:00:00', 'Internet bill', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 800.00, 'Expense', 'Rent', '2026-08-01 07:30:00', 'Apartment rent', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 200.00, 'Expense', 'Transportation', '2026-08-06 08:00:00', 'Monthly bus pass', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 75.25, 'Expense', 'Healthcare', '2026-08-08 14:30:00', 'Pharmacy purchases', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'analyst'
ON CONFLICT DO NOTHING;

-- Viewer's records
INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 3500.00, 'Income', 'Salary', '2026-08-01 09:00:00', 'Monthly income', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'viewer'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 100.00, 'Expense', 'Groceries', '2026-08-04 19:00:00', 'Weekly groceries', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'viewer'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 50.00, 'Expense', 'Utilities', '2026-08-05 12:00:00', 'Water bill', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'viewer'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 600.00, 'Expense', 'Rent', '2026-08-01 08:00:00', 'Monthly rent', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'viewer'
ON CONFLICT DO NOTHING;

-- Test user's records
INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 4000.00, 'Income', 'Salary', '2026-08-01 09:00:00', 'Monthly salary', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'testuser'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 250.00, 'Income', 'Investment', '2026-08-12 10:00:00', 'Stock dividend payment', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'testuser'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 180.00, 'Expense', 'Groceries', '2026-08-05 18:00:00', 'Grocery shopping', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'testuser'
ON CONFLICT DO NOTHING;

INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 95.00, 'Expense', 'Utilities', '2026-08-06 13:00:00', 'Gas and electric', FALSE, NULL, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'testuser'
ON CONFLICT DO NOTHING;

-- Sample of soft-deleted record (for testing IsDeleted filter)
INSERT INTO "FinancialRecords" ("UserId", "Amount", "Type", "Category", "Date", "Notes", "IsDeleted", "DeletedAt", "CreatedAt")
SELECT u."Id", 999.99, 'Expense', 'Test', '2026-08-01 12:00:00', 'This record is soft deleted', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM "Users" u WHERE u."Username" = 'admin'
ON CONFLICT DO NOTHING;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Count users by role
SELECT "Role", COUNT(*) as UserCount
FROM "Users"
GROUP BY "Role"
ORDER BY "Role";

-- Count active vs inactive users
SELECT "IsActive", COUNT(*) as UserCount
FROM "Users"
GROUP BY "IsActive";

-- Summary of financial records by type
SELECT "Type", COUNT(*) as RecordCount, SUM("Amount") as TotalAmount
FROM "FinancialRecords"
WHERE "IsDeleted" = FALSE
GROUP BY "Type"
ORDER BY "Type";

-- Records per user
SELECT u."Username", u."Role", COUNT(fr."Id") as RecordCount
FROM "Users" u
LEFT JOIN "FinancialRecords" fr ON u."Id" = fr."UserId" AND fr."IsDeleted" = FALSE
GROUP BY u."Id", u."Username", u."Role"
ORDER BY u."Id";

-- Show all users with their total income and expenses
SELECT 
    u."Username",
    u."Role",
    COALESCE(SUM(CASE WHEN fr."Type" = 'Income' THEN fr."Amount" ELSE 0 END), 0) as TotalIncome,
    COALESCE(SUM(CASE WHEN fr."Type" = 'Expense' THEN fr."Amount" ELSE 0 END), 0) as TotalExpenses,
    COALESCE(SUM(CASE WHEN fr."Type" = 'Income' THEN fr."Amount" ELSE -fr."Amount" END), 0) as NetBalance
FROM "Users" u
LEFT JOIN "FinancialRecords" fr ON u."Id" = fr."UserId" AND fr."IsDeleted" = FALSE
WHERE u."IsActive" = TRUE
GROUP BY u."Id", u."Username", u."Role"
ORDER BY u."Id";

-- =====================================================
-- SAMPLE LOGIN CREDENTIALS (DEVELOPMENT ONLY)
-- =====================================================
-- 
-- Username: admin          | Password: Admin@123      | Role: Admin
-- Username: analyst        | Password: Analyst@123    | Role: Analyst  
-- Username: viewer         | Password: Viewer@123     | Role: Viewer
-- Username: testuser       | Password: Test@123       | Role: Analyst
-- Username: inactive_user  | Password: Inactive@123   | Role: Viewer (Inactive)
--
-- ✅ All BCrypt hashes have been verified with BCrypt.Net-Next (Cost: 11)
-- ⚠️  IMPORTANT: These are sample credentials for LOCAL DEVELOPMENT ONLY
-- ⚠️  NEVER commit real production passwords to version control
-- ⚠️  Use environment variables or secure secrets management in production
-- =====================================================
