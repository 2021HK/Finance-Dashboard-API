# PostgreSQL Database Scripts

## 📁 Files Overview

### **01_CreateSchema.sql**
Creates the complete database schema:
- `Users` table with roles and authentication
- `FinancialRecords` table with transactions
- Foreign key relationships
- Indexes for performance
- Constraints for data integrity

**Features:**
- ✅ Serial primary keys (auto-increment)
- ✅ Unique constraint on Username
- ✅ Foreign key with CASCADE delete
- ✅ Check constraints (Type, Amount)
- ✅ Indexes on frequently queried columns
- ✅ Soft delete support (IsDeleted)
- ✅ Timestamp tracking (CreatedAt, UpdatedAt)

### **02_SeedData.sql**
Sample data for testing and development:
- 5 test users (Admin, Analyst, Viewer roles)
- ~20+ financial records (Income/Expense)
- BCrypt hashed passwords

---

## 🚀 Quick Start

### **Method 1: pgAdmin GUI**

1. Open **pgAdmin 4**
2. Create database `FinanceDashboardDB`
3. Open Query Tool
4. Run `01_CreateSchema.sql`
5. Run `02_SeedData.sql`
6. Verify with built-in queries

### **Method 2: psql Command Line**

```bash
# Create database
psql -U postgres -c "CREATE DATABASE \"FinanceDashboardDB\";"

# Execute schema
psql -U postgres -d FinanceDashboardDB -f 01_CreateSchema.sql

# Execute seed data
psql -U postgres -d FinanceDashboardDB -f 02_SeedData.sql

# Verify
psql -U postgres -d FinanceDashboardDB -c "SELECT COUNT(*) FROM \"Users\";"
```

---

## 📊 Database Schema

### **Users Table**
```sql
CREATE TABLE "Users" (
    "Id" SERIAL PRIMARY KEY,
    "Username" VARCHAR(255) NOT NULL UNIQUE,
    "PasswordHash" TEXT NOT NULL,
    "Role" VARCHAR(50) NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITHOUT TIME ZONE
);
```

**Roles:**
- `Admin` - Full system access
- `Analyst` - Manage financial records
- `Viewer` - Read-only access

### **FinancialRecords Table**
```sql
CREATE TABLE "FinancialRecords" (
    "Id" SERIAL PRIMARY KEY,
    "UserId" INTEGER NOT NULL,
    "Amount" NUMERIC(18, 2) NOT NULL,
    "Type" VARCHAR(10) NOT NULL CHECK ("Type" IN ('Income', 'Expense')),
    "Category" VARCHAR(100) NOT NULL,
    "Date" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "Notes" VARCHAR(500),
    "IsDeleted" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITHOUT TIME ZONE,
    "DeletedAt" TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT "FK_FinancialRecords_Users_UserId" 
        FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
```

**Transaction Types:**
- `Income` - Money received
- `Expense` - Money spent

**Common Categories:**
- Salary, Bonus, Freelance, Investment (Income)
- Rent, Groceries, Utilities, Healthcare, Entertainment (Expense)

---

## 🔑 Test Credentials (Development Only)

| Username | Password | Role | Records | Active |
|----------|----------|------|---------|--------|
| `admin` | `Admin@123` | Admin | 6 | ✅ Yes |
| `analyst` | `Analyst@123` | Analyst | 7 | ✅ Yes |
| `viewer` | `Viewer@123` | Viewer | 4 | ✅ Yes |
| `testuser` | `Test@123` | Analyst | 4 | ✅ Yes |
| `inactive_user` | (N/A) | Viewer | 0 | ❌ No |

⚠️ **IMPORTANT:** These are for LOCAL DEVELOPMENT ONLY. Change passwords in production!

---

## 🔍 Useful Queries

### Check if tables exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('Users', 'FinancialRecords');
```

### View all users
```sql
SELECT "Id", "Username", "Role", "IsActive", "CreatedAt" 
FROM "Users" 
ORDER BY "Id";
```

### View financial records (excluding soft deleted)
```sql
SELECT fr."Id", u."Username", fr."Amount", fr."Type", fr."Category", fr."Date"
FROM "FinancialRecords" fr
JOIN "Users" u ON fr."UserId" = u."Id"
WHERE fr."IsDeleted" = FALSE
ORDER BY fr."Date" DESC;
```

### User financial summary
```sql
SELECT 
    u."Username",
    u."Role",
    SUM(CASE WHEN fr."Type" = 'Income' THEN fr."Amount" ELSE 0 END) as "TotalIncome",
    SUM(CASE WHEN fr."Type" = 'Expense' THEN fr."Amount" ELSE 0 END) as "TotalExpenses",
    SUM(CASE WHEN fr."Type" = 'Income' THEN fr."Amount" ELSE -fr."Amount" END) as "NetBalance"
FROM "Users" u
LEFT JOIN "FinancialRecords" fr ON u."Id" = fr."UserId" AND fr."IsDeleted" = FALSE
WHERE u."IsActive" = TRUE
GROUP BY u."Id", u."Username", u."Role"
ORDER BY u."Id";
```

### View foreign key constraints
```sql
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

### View table indexes
```sql
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

---

## 🧹 Reset Database (Clean Slate)

If you need to start fresh:

```sql
-- Drop all records (keeps structure)
TRUNCATE TABLE "FinancialRecords" CASCADE;
TRUNCATE TABLE "Users" CASCADE;

-- Or drop and recreate (loses everything)
DROP TABLE IF EXISTS "FinancialRecords" CASCADE;
DROP TABLE IF EXISTS "Users" CASCADE;

-- Then re-run 01_CreateSchema.sql and 02_SeedData.sql
```

---

## 🔐 Security Best Practices

### **For Development:**
- ✅ Use default `postgres` user locally
- ✅ Simple passwords are fine (postgres/postgres)
- ✅ Connection: `localhost:5432`

### **For Production:**
- ✅ Create dedicated application user
  ```sql
  CREATE USER finance_app WITH PASSWORD 'secure_random_password';
  GRANT CONNECT ON DATABASE "FinanceDashboardDB" TO finance_app;
  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO finance_app;
  GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO finance_app;
  ```
- ✅ Use SSL connections (`SSL Mode=Require`)
- ✅ Restrict network access (firewall rules)
- ✅ Use AWS RDS with IAM authentication
- ✅ Store connection strings in environment variables
- ✅ Never commit credentials to version control

---

## 📚 PostgreSQL Resources

- **Official Docs:** https://www.postgresql.org/docs/
- **pgAdmin Manual:** https://www.pgadmin.org/docs/
- **SQL Tutorial:** https://www.postgresqltutorial.com/
- **EF Core Provider:** https://www.npgsql.org/efcore/

---

## 🐛 Common Issues

### **"relation does not exist"**
- Table names are case-sensitive in PostgreSQL
- Use double quotes: `"Users"` not `users`
- Check if schema was executed successfully

### **"password authentication failed"**
- Check PostgreSQL password (set during installation)
- Default user: `postgres`
- Reset password: `ALTER USER postgres WITH PASSWORD 'new_password';`

### **"could not connect to server"**
- Verify PostgreSQL service is running
- Windows: Services → postgresql-x64-16
- Check port 5432 is not blocked

### **"permission denied for table"**
- Grant appropriate permissions to user
- Or use `postgres` superuser for development

---

**Database Scripts Version:** 1.0  
**PostgreSQL Version:** 16+  
**Encoding:** UTF-8  
**Timezone:** UTC
