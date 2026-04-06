# Finance Dashboard API

A RESTful backend API built using ASP.NET Core 8.0 for managing financial records such as income and expenses, with secure authentication and role-based access control.

## Overview

This project is designed as a backend system for a finance dashboard application. It allows users to manage financial transactions while enforcing access control based on different user roles.

It also provides a dashboard summary to track total income, expenses, and overall balance.

---

## Key Features

User Management

* Create, update, and delete users
* Assign roles (Admin, Analyst, Viewer)

Financial Records

* Add, update, and delete income/expense records
* Categorize transactions
* Soft delete support (no permanent deletion)

Dashboard

* Total income calculation
* Total expense calculation
* Net balance
* Total transactions

Security

* JWT authentication
* Password hashing using BCrypt
* Role-based authorization
* Token expiration

System Reliability

* Global error handling
* Input validation
* Clean API responses

---

## Tech Stack

* ASP.NET Core 8.0
* SQL Server
* Entity Framework Core
* JWT Authentication
* BCrypt for password hashing
* Swagger for API documentation

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

Prerequisites:

* .NET 8 SDK
* SQL Server
* Visual Studio / VS Code

Steps:

1. Clone the repository
   git clone <repo-url>
   cd FinanceDashboardAPI

2. Update connection string in appsettings.json

3. Run database migration
   dotnet ef database update

4. Run the project
   dotnet run

5. Open Swagger
   https://localhost:<port>/swagger

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

## Database Design

Users Table:

* Id
* Username
* PasswordHash
* Role
* IsActive
* CreatedAt
* UpdatedAt

FinancialRecords Table:

* Id
* UserId
* Amount
* Type (Income/Expense)
* Category
* Date
* Notes
* IsDeleted

---

## Testing

* Tested using Swagger UI
* Verified CRUD operations
* Checked role-based access
* Used sample financial data

---

## Design Decisions

* Soft delete used for data safety
* JWT expiry set to 60 minutes
* Simple role structure (Admin, Analyst, Viewer)
* Focus on clean and maintainable architecture

---

## Learning Outcomes

* REST API development
* JWT authentication
* Role-based authorization
* Entity Framework Core
* Clean architecture design
* Error handling and validation

--
## Conclusion

This API provides a structured and secure backend system for managing financial data with scalability and maintainability.
