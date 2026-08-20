# Finance Dashboard API

A RESTful backend API built using **ASP.NET Core 10.0** for managing financial records such as income and expenses, with secure authentication and role-based access control.

## Overview

This project is designed as a backend system for a finance dashboard application. It allows users to manage financial transactions while enforcing access control based on different user roles.

It also provides a dashboard summary to track total income, expenses, and overall balance.

---

## Key Features

**User Management**

* Create, update, and delete users
* Assign roles (Admin, Analyst, Viewer)
* Password encryption with BCrypt

**Financial Records**

* Add, update, and delete income/expense records
* Categorize transactions (Salary, Rent, Food, etc.)
* Soft delete support (no permanent deletion)
* Date/time handling with UTC

**Dashboard**

* Total income calculation
* Total expense calculation
* Net balance tracking
* Transaction count

**Security**

* JWT token-based authentication
* Password hashing using BCrypt
* Role-based authorization (Admin, Analyst, Viewer)
* Token expiration (60 minutes)
* Secure password storage

**System Reliability**

* Global error handling middleware
* Input validation with data annotations
* Clean and consistent API responses
* CORS enabled for cross-origin requests

---

## Tech Stack

* **ASP.NET Core 10.0** - Web API Framework
* **PostgreSQL** - Relational Database
* **Entity Framework Core 10** - ORM (Database-First)
* **Npgsql** - PostgreSQL provider for EF Core
* **JWT Authentication** - Token-based security
* **BCrypt.Net-Next** - Password hashing
* **Swagger/OpenAPI** - API documentation and testing

---

## Architecture

Controllers → Services → Repositories → Database

Layers:

* Controllers: Handle HTTP requests
* Services: Business logic
* Repositories: Database operations
* Models: Database entities
* DTOs: Data transfer objects
* Middleware: Error handling

---

## Setup Instructions

**Prerequisites:**

* .NET 10 SDK
* PostgreSQL 16+ (with pgAdmin or psql)
* Visual Studio 2022 / VS Code
* Postman (optional for API testing)

**Steps:**

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd FinanceDashboardAPI
   ```

2. **Install PostgreSQL and create database**
   ```sql
   CREATE DATABASE "FinanceDashboardDB";
   ```

3. **Execute database schema script**
   ```bash
   psql -U postgres -d FinanceDashboardDB -f DatabaseScripts/PostgreSQL/01_CreateSchema.sql
   psql -U postgres -d FinanceDashboardDB -f DatabaseScripts/PostgreSQL/02_SeedData.sql
   ```

4. **Update connection string in `appsettings.Development.json`**
   ```json
   "DefaultConnection": "Host=localhost;Port=5432;Database=FinanceDashboardDB;Username=postgres;Password=your_password"
   ```

5. **Restore packages and build**
   ```bash
   dotnet restore
   dotnet build
   ```

6. **Run the project**
   ```bash
   dotnet run
   ```

7. **Open Swagger UI**
   ```
   https://localhost:7XXX/swagger
   ```

8. **Test login with sample credentials**
   - Username: `admin` | Password: `Admin@123`
   - Username: `analyst` | Password: `Analyst@123`
   - Username: `viewer` | Password: `Viewer@123`

---

## Authentication Flow

1. Login using:
   POST /api/auth/login

2. Get JWT token

3. Use token in headers:
   Authorization: Bearer <token>

---

## Roles & Permissions

Admin:

* Full access

Analyst:

* Can manage financial records

Viewer:

* Can only view records and dashboard

---

## API Endpoints

Authentication:

* POST /api/auth/login

Users (Admin Only):

* GET /api/users
* POST /api/users
* PUT /api/users/{id}
* DELETE /api/users/{id}

Financial Records:

* GET /api/records
* POST /api/records
* PUT /api/records/{id}
* DELETE /api/records/{id}

Dashboard:

* GET /api/dashboard/summary

---

## Database Design (PostgreSQL)

**Users Table:**
```sql
Id (SERIAL PRIMARY KEY)
Username (VARCHAR 255, UNIQUE)
PasswordHash (TEXT)
Role (VARCHAR 50) - Admin, Analyst, Viewer
IsActive (BOOLEAN)
CreatedAt (TIMESTAMP)
UpdatedAt (TIMESTAMP)
```

**FinancialRecords Table:**
```sql
Id (SERIAL PRIMARY KEY)
UserId (INTEGER, FOREIGN KEY → Users.Id)
Amount (NUMERIC 18,2)
Type (VARCHAR 10) - Income/Expense
Category (VARCHAR 100)
Date (TIMESTAMP)
Notes (VARCHAR 500)
IsDeleted (BOOLEAN) - Soft delete
CreatedAt (TIMESTAMP)
UpdatedAt (TIMESTAMP)
DeletedAt (TIMESTAMP)
```

**Relationships:**
- One User → Many FinancialRecords
- CASCADE delete on user removal

---

## Testing

* Tested using Swagger UI
* Verified CRUD operations
* Checked role-based access
* Used sample financial data

---

## Design Decisions

* **Database-First Approach** - Schema created in PostgreSQL first, then scaffolded
* **Soft Delete** - Records marked as deleted, not physically removed
* **JWT Token Expiry** - 60 minutes for security
* **Three-Tier Architecture** - Controllers → Services → Repositories
* **Repository Pattern** - Abstraction over data access
* **Dependency Injection** - All services registered in Program.cs
* **Role-Based Security** - Admin, Analyst, Viewer with different permissions
* **DateTime Handling** - UTC timestamps for consistency
* **Password Security** - BCrypt hashing with salt (cost factor 11)

---

## Project Structure

```
FinanceDashboardAPI/
├── Controllers/          # HTTP endpoints
│   ├── AuthController.cs
│   ├── UsersController.cs
│   ├── RecordsController.cs
│   └── DashboardController.cs
├── Services/            # Business logic
│   ├── AuthService.cs
│   ├── UserService.cs
│   ├── FinancialRecordService.cs
│   └── DashboardService.cs
├── Repositories/        # Data access
│   ├── UserRepository.cs
│   └── FinancialRecordRepository.cs
├── Models/              # Database entities
│   ├── User.cs
│   └── FinancialRecord.cs
├── DTOs/                # Data transfer objects
├── Data/                # DbContext
├── Helpers/             # JWT helper
├── Middleware/          # Error handling
├── Constants/           # Roles, TransactionTypes
└── DatabaseScripts/     # PostgreSQL SQL files
```

---

## Key Concepts Implemented

**1. Dependency Injection**
- Services, Repositories registered in `Program.cs`
- Constructor injection in Controllers and Services
- Loose coupling between layers

**2. Repository Pattern**
- Interface-based data access (`IUserRepository`, `IFinancialRecordRepository`)
- Separation of data logic from business logic
- Easy to mock for testing

**3. JWT Authentication**
- Token generation with user claims (Id, Username, Role)
- Token validation in middleware
- Role-based authorization on controllers

**4. Clean Architecture**
- Separation of concerns
- Single Responsibility Principle
- Dependency Inversion Principle

**5. Error Handling**
- Global exception middleware
- Consistent error responses
- Try-catch in service layer

**6. Entity Framework Core**
- Code-First models with Database-First approach
- DbContext configuration
- Fluent API for relationships
- Query filters for soft delete

---

## Learning Outcomes

* ✅ RESTful API design and implementation
* ✅ JWT token-based authentication and authorization
* ✅ Role-based access control (RBAC)
* ✅ Entity Framework Core with PostgreSQL
* ✅ Database-First development approach
* ✅ Repository and Service patterns
* ✅ Dependency Injection in ASP.NET Core
* ✅ Clean layered architecture
* ✅ Global error handling middleware
* ✅ Password hashing and security best practices
* ✅ Soft delete implementation
* ✅ Input validation with Data Annotations
* ✅ Swagger/OpenAPI documentation

---

## Future Enhancements

* Unit testing with xUnit
* Integration testing
* Docker containerization
* CI/CD pipeline (GitHub Actions)
* AWS deployment (EC2, RDS)
* Logging with Serilog
* Caching with Redis
* API versioning
* Pagination for large datasets

---

## Conclusion

This API demonstrates a production-ready backend system for financial data management with proper architecture, security, and scalability considerations. Built using modern .NET practices and PostgreSQL for robust data storage.
