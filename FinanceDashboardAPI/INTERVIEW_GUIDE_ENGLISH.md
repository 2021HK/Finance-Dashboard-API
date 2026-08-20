# Interview Preparation Guide - Finance Dashboard API
## Complete Technical Guide for Freshers

---

## Table of Contents
1. [Dependency Injection](#1-dependency-injection)
2. [Repository Pattern](#2-repository-pattern)
3. [Three-Tier Architecture](#3-three-tier-architecture)
4. [JWT Authentication](#4-jwt-authentication)
5. [Entity Framework Core](#5-entity-framework-core)
6. [Role-Based Authorization](#6-role-based-authorization)
7. [Middleware](#7-middleware)
8. [DTOs (Data Transfer Objects)](#8-dtos-data-transfer-objects)
9. [Common Interview Questions](#9-common-interview-questions)
10. [Project Explanation](#10-project-explanation)

---

## 1. Dependency Injection

### **What is Dependency Injection?**

**Definition:**  
Dependency Injection is a design pattern where a class receives its dependencies from external sources rather than creating them itself.

### **Real Example:**

**❌ Without DI (Bad Practice):**
```csharp
public class UsersController
{
    private UserService _userService;
    
    public UsersController()
    {
        // Controller creates its own dependency - TIGHT COUPLING
        _userService = new UserService();
    }
}
```
**Problem:** If UserService changes, the controller must also change.

**✅ With DI (Best Practice):**
```csharp
public class UsersController
{
    private readonly IUserService _userService;
    
    // Constructor injection - dependency provided externally
    public UsersController(IUserService userService)
    {
        _userService = userService;
    }
}
```
**Benefits:** 
- Loose coupling
- Easy to test with mock objects
- Flexible implementation changes

---

### **Interview Q&A:**

**Q1: What is Dependency Injection?**

**Answer:**  
"Dependency Injection is a design pattern where a class doesn't create its own dependencies but receives them through constructor or method parameters. This promotes loose coupling and makes code more testable and maintainable.

In my project, I use constructor injection throughout. For example, my `UsersController` receives `IUserService` through its constructor, and ASP.NET Core's built-in DI container automatically provides the `UserService` implementation."

---

**Q2: What are the benefits of Dependency Injection?**

**Answer:**  
"There are four main benefits:

1. **Loose Coupling** - Classes are independent and don't depend on concrete implementations
2. **Testability** - We can easily inject mock objects for unit testing
3. **Flexibility** - We can change implementations without modifying client code
4. **Maintainability** - Code is cleaner and easier to maintain

For example, if I want to use a different implementation of `IUserService` for testing, I only need to change the DI registration, not the controller code."

---

**Q3: What are the three DI lifetime types in ASP.NET Core?**

**Answer:**

| Lifetime | When Created | Use Case |
|----------|-------------|----------|
| **Transient** | Every time it's requested | Lightweight, stateless services |
| **Scoped** | Once per HTTP request | DbContext, Repositories |
| **Singleton** | Once for application lifetime | Configuration, Caching, Stateless helpers |

**In my project:**
```csharp
// Scoped - New instance per HTTP request
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

// Singleton - One instance for entire application
builder.Services.AddSingleton<JwtHelper>();

// DbContext is always Scoped
builder.Services.AddDbContext<AppDbContext>(options => 
    options.UseNpgsql(connectionString));
```

**Why Scoped for DbContext?**  
"DbContext tracks entity changes, so it should be scoped to a single request to avoid conflicts. A new DbContext is created for each HTTP request."

---

**Q4: Where do you register services in ASP.NET Core?**

**Answer:**  
"Services are registered in the `Program.cs` file using the `builder.Services` collection before building the application.

In my project, I register all services, repositories, and DbContext in `Program.cs`:"

```csharp
// Database
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IFinancialRecordRepository, FinancialRecordRepository>();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IFinancialRecordService, FinancialRecordService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();

// Helpers
builder.Services.AddSingleton<JwtHelper>();
```

---

## 2. Repository Pattern

### **What is the Repository Pattern?**

**Definition:**  
The Repository Pattern is a design pattern that creates an abstraction layer between the data access logic and the business logic. It encapsulates all database operations.

### **Why Use Repository Pattern?**

1. **Separation of Concerns** - Data access logic is separated from business logic
2. **Testability** - Easy to create mock repositories for unit testing
3. **Centralized Data Logic** - All database operations in one place
4. **Database Independence** - Can switch databases without changing business logic

### **Interview Answer:**

**Q: Explain the Repository Pattern in your project.**

**Answer:**  
"The Repository Pattern provides an abstraction over data access. Instead of controllers directly accessing the database through DbContext, they use repository interfaces.

In my project, I have repositories for each entity:

```csharp
// Interface defines the contract
public interface IUserRepository
{
    List<User> GetAll();
    User GetById(int id);
    void Add(User user);
    void Update(User user);
}

// Implementation handles actual database operations
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;
    
    public UserRepository(AppDbContext context)
    {
        _context = context; // Injected via DI
    }
    
    public List<User> GetAll()
    {
        return _context.Users.ToList();
    }
    
    public User GetById(int id)
    {
        return _context.Users.Find(id);
    }
    
    public void Add(User user)
    {
        _context.Users.Add(user);
        _context.SaveChanges();
    }
}
```

**Benefits in my project:**
- Services don't need to know about EF Core or SQL
- If I want to switch from PostgreSQL to MongoDB, I only change the repository implementation
- Easy to mock repositories for testing services"

---

## 3. Three-Tier Architecture

### **Architecture Layers:**

```
Client → Controller → Service → Repository → Database
```

| Layer | Responsibility | Example from Project |
|-------|---------------|---------------------|
| **Controller** | Handle HTTP requests/responses | `UsersController` |
| **Service** | Business logic & validation | `UserService` |
| **Repository** | Database operations | `UserRepository` |
| **Database** | Data persistence | PostgreSQL |

### **Interview Explanation:**

**Q: Explain the architecture of your project.**

**Answer:**  
"My project follows a three-tier layered architecture with clear separation of concerns:

**1. Controller Layer** - Handles HTTP requests and responses
```csharp
[HttpPost]
public IActionResult CreateUser([FromBody] CreateUserDto dto)
{
    var user = _userService.Create(dto); // Delegates to service
    return Ok(new { message = "User created", user });
}
```

**2. Service Layer** - Contains business logic
```csharp
public UserDto Create(CreateUserDto dto)
{
    // Validate business rules
    if (_repository.UsernameExists(dto.Username))
        throw new InvalidOperationException("Username already exists");
    
    // Hash password
    var passwordHash = BCrypt.HashPassword(dto.Password);
    
    // Create entity
    var user = new User 
    { 
        Username = dto.Username, 
        PasswordHash = passwordHash 
    };
    
    // Call repository to save
    _repository.Add(user);
    
    return MapToDto(user);
}
```

**3. Repository Layer** - Database access
```csharp
public void Add(User user)
{
    _context.Users.Add(user);
    _context.SaveChanges();
}
```

**Flow Example - Creating a User:**
```
POST /api/users
    ↓
UsersController.CreateUser()
    ↓
UserService.Create() (validates, hashes password)
    ↓
UserRepository.Add() (saves to database)
    ↓
PostgreSQL Database
```

**Benefits:**
- Each layer has single responsibility
- Easy to test each layer independently
- Changes in one layer don't affect others
- Clear code organization"

---

## 4. JWT Authentication

### **What is JWT?**

**Definition:**  
JWT (JSON Web Token) is a compact, URL-safe token format used for securely transmitting information between parties. It's used for authentication and authorization.

### **JWT Structure:**
```
Header.Payload.Signature

Example:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

- **Header**: Algorithm and token type
- **Payload**: Claims (user data)
- **Signature**: Verifies token hasn't been tampered with

### **Interview Q&A:**

**Q: How does JWT authentication work in your project?**

**Answer:**  
"JWT authentication in my project works in three steps:

**Step 1: User Login**
```csharp
POST /api/auth/login
{
  "username": "admin",
  "password": "Admin@123"
}
```
- User sends credentials
- Service verifies password using BCrypt
- If valid, generates JWT token

**Step 2: Token Generation**
```csharp
public string GenerateToken(User user)
{
    var claims = new[]
    {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Name, user.Username),
        new Claim(ClaimTypes.Role, user.Role)
    };
    
    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secret));
    var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    
    var token = new JwtSecurityToken(
        expires: DateTime.UtcNow.AddMinutes(60),
        claims: claims,
        signingCredentials: credentials
    );
    
    return new JwtSecurityTokenHandler().WriteToken(token);
}
```

**Step 3: Using the Token**
```http
GET /api/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
```

- Client includes token in Authorization header
- Authentication middleware validates token
- Extracts claims (user ID, username, role)
- Checks authorization based on role

**Security Features:**
- Token expires after 60 minutes
- Signed with secret key to prevent tampering
- Stateless - server doesn't store tokens
- Contains user claims for authorization"

---

## 5. Entity Framework Core

### **What is EF Core?**

**Definition:**  
Entity Framework Core is an Object-Relational Mapper (ORM) that enables .NET developers to work with databases using .NET objects, eliminating the need for most data-access code.

### **Code vs SQL:**

**Without EF Core (Raw SQL):**
```sql
SELECT * FROM Users WHERE Id = @id;
INSERT INTO Users (Username, PasswordHash) VALUES (@username, @password);
```

**With EF Core (C# LINQ):**
```csharp
var user = _context.Users.Find(id);
_context.Users.Add(new User { Username = "john", PasswordHash = "hash" });
_context.SaveChanges();
```

### **Interview Q&A:**

**Q1: What is Entity Framework Core and why use it?**

**Answer:**  
"Entity Framework Core is an ORM that maps C# classes to database tables. Instead of writing SQL queries, we work with C# objects.

**Benefits:**
1. **Type Safety** - Compile-time checking, no SQL syntax errors
2. **Productivity** - Less code to write
3. **LINQ Support** - Powerful query syntax
4. **Database Independence** - Can switch databases with minimal code changes
5. **Migration Support** - Automatic schema management

In my project, EF Core handles all database operations through repositories."

---

**Q2: What is the difference between Database-First and Code-First?**

**Answer:**

| Approach | Workflow | When to Use |
|----------|----------|-------------|
| **Code-First** | Write C# models → Generate database | New projects, full control |
| **Database-First** | Create database → Generate C# models | Existing database, DBA-controlled schema |

**I used Database-First because:**

1. Database schema was designed first in PostgreSQL
2. SQL scripts were already created
3. DBA could manage database independently
4. Better control over PostgreSQL-specific features

**My Process:**
```bash
# 1. Created database schema in PostgreSQL
psql -U postgres -d FinanceDashboardDB -f 01_CreateSchema.sql

# 2. Scaffolded EF Core models from database
dotnet ef dbcontext scaffold "Host=localhost;..." 
    Npgsql.EntityFrameworkCore.PostgreSQL 
    --context AppDbContext 
    --output-dir Models
```

**Benefits:**
- Database structure was clear from SQL scripts
- Could optimize PostgreSQL-specific features
- Team could review database design before coding"

---

**Q3: What is DbContext?**

**Answer:**  
"DbContext is the primary class for interacting with the database in EF Core. It represents a session with the database and provides DbSet properties for each entity.

In my project:
```csharp
public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    public DbSet<FinancialRecord> FinancialRecords { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure relationships
        modelBuilder.Entity<FinancialRecord>()
            .HasOne(e => e.User)
            .WithMany(u => u.FinancialRecords)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);
            
        // Configure soft delete filter
        modelBuilder.Entity<FinancialRecord>()
            .HasQueryFilter(e => !e.IsDeleted);
    }
}
```

DbContext is registered as Scoped in DI, so each HTTP request gets its own instance."

---

## 6. Role-Based Authorization (RBAC)

### **What is RBAC?**

**Definition:**  
Role-Based Access Control restricts system access based on user roles. Different roles have different permissions.

### **Roles in My Project:**

| Role | Permissions |
|------|-------------|
| **Admin** | Full access - manage users, manage records, view dashboard |
| **Analyst** | Manage financial records, view dashboard (no user management) |
| **Viewer** | Read-only access - view records and dashboard only |

### **Implementation:**

```csharp
// Admin-only endpoint
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    // Only Admin can access these endpoints
}

// Multiple roles
[Authorize(Roles = "Admin,Analyst")]
[HttpPost]
public IActionResult CreateRecord(CreateRecordDto dto)
{
    // Admin or Analyst can create records
}

// Any authenticated user
[Authorize]
[HttpGet]
public IActionResult GetRecords()
{
    // Any logged-in user can view
}
```

### **Interview Answer:**

**Q: How did you implement role-based authorization?**

**Answer:**  
"I implemented role-based authorization using ASP.NET Core's built-in `[Authorize]` attribute with role requirements.

**Implementation Steps:**

1. **Define Roles** - Created a constants class
```csharp
public static class Roles
{
    public const string Admin = "Admin";
    public const string Analyst = "Analyst";
    public const string Viewer = "Viewer";
}
```

2. **Store Role in JWT Token**
```csharp
var claims = new[]
{
    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
    new Claim(ClaimTypes.Name, user.Username),
    new Claim(ClaimTypes.Role, user.Role) // Role claim
};
```

3. **Apply Authorization Attributes**
```csharp
[Authorize(Roles = Roles.Admin)]
public class UsersController : ControllerBase
{
    // Only Admin can manage users
}
```

4. **Middleware Checks**
- Authentication middleware validates JWT token
- Authorization middleware checks role claims
- If user's role doesn't match, returns 403 Forbidden

**Example Flow:**
```
User (Analyst role) → POST /api/users
    ↓
Authentication Middleware → Validates JWT ✓
    ↓
Authorization Middleware → Checks role claim
    ↓
Role is 'Analyst' but endpoint requires 'Admin'
    ↓
403 Forbidden Response
```

This ensures proper access control without writing authorization logic in every endpoint."

---

## 7. Middleware

### **What is Middleware?**

**Definition:**  
Middleware is software that sits between the HTTP request and the controller. It forms a pipeline where each middleware can process the request before passing it to the next middleware.

### **Middleware Pipeline:**

```
HTTP Request
    ↓
Error Handling Middleware
    ↓
Authentication Middleware
    ↓
Authorization Middleware
    ↓
Controller
    ↓
HTTP Response
```

### **Interview Answer:**

**Q: What is middleware and how did you use it?**

**Answer:**  
"Middleware is a component that forms a request processing pipeline in ASP.NET Core. Each middleware can process the request, call the next middleware, and process the response.

**In my project, I use several middlewares:**

```csharp
// Program.cs - Order matters!
app.UseMiddleware<ErrorHandlingMiddleware>(); // 1. Catch all errors
app.UseAuthentication();                       // 2. Validate JWT token
app.UseAuthorization();                        // 3. Check permissions
app.MapControllers();                          // 4. Route to controllers
```

**Custom Error Handling Middleware:**
```csharp
public class ErrorHandlingMiddleware
{
    private readonly RequestDelegate _next;
    
    public ErrorHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context); // Call next middleware
        }
        catch (KeyNotFoundException ex)
        {
            context.Response.StatusCode = 404;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Not Found", 
                message = ex.Message 
            });
        }
        catch (UnauthorizedAccessException ex)
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Unauthorized", 
                message = ex.Message 
            });
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Server Error", 
                message = "An unexpected error occurred" 
            });
        }
    }
}
```

**Benefits:**
- Centralized error handling
- Consistent error responses
- No try-catch needed in every controller
- Clean separation of cross-cutting concerns"

---

## 8. DTOs (Data Transfer Objects)

### **What are DTOs?**

**Definition:**  
DTOs are simple objects used to transfer data between layers or across network boundaries. They don't contain business logic, only data.

### **Why Use DTOs?**

1. **Security** - Hide sensitive data (passwords, internal IDs)
2. **Decoupling** - API contract independent of database schema
3. **Validation** - Apply input validation attributes
4. **Performance** - Transfer only required data

### **Example:**

```csharp
// Database Entity - Internal model
public class User
{
    public int Id { get; set; }
    public string Username { get; set; }
    public string PasswordHash { get; set; } // SENSITIVE!
    public string Role { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}

// DTO for API Response - Public facing
public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; }
    public string Role { get; set; }
    // No PasswordHash - security!
    // No CreatedAt - not needed by client
}

// DTO for Creating User - Input validation
public class CreateUserDto
{
    [Required(ErrorMessage = "Username is required")]
    [StringLength(50, MinimumLength = 3)]
    public string Username { get; set; }
    
    [Required(ErrorMessage = "Password is required")]
    [MinLength(8, ErrorMessage = "Password must be at least 8 characters")]
    public string Password { get; set; } // Plain password from client
    
    [Required]
    [RegularExpression("^(Admin|Analyst|Viewer)$")]
    public string Role { get; set; }
}
```

### **Interview Answer:**

**Q: Why do you use DTOs instead of returning entities directly?**

**Answer:**  
"I use DTOs for several important reasons:

**1. Security**
```csharp
// Without DTO - BAD
return Ok(user); // Exposes PasswordHash!

// With DTO - GOOD
return Ok(new UserDto 
{ 
    Id = user.Id, 
    Username = user.Username, 
    Role = user.Role 
}); // PasswordHash hidden
```

**2. Input Validation**
DTOs have validation attributes:
```csharp
public class CreateUserDto
{
    [Required]
    [MinLength(8)]
    public string Password { get; set; }
}
```
ASP.NET Core validates automatically. If validation fails, returns 400 Bad Request.

**3. API Contract Stability**
If I add fields to the User entity (like `LastLoginDate`), it doesn't affect existing API responses. DTOs control what clients see.

**4. Performance**
Transfer only necessary data. If client needs just username and role, DTO contains only those fields, not entire entity.

**Mapping Example:**
```csharp
public UserDto MapToDto(User user)
{
    return new UserDto
    {
        Id = user.Id,
        Username = user.Username,
        Role = user.Role
    };
}
```

This separation keeps the API clean, secure, and flexible."

---

## 9. Common Interview Questions

### **Q1: Explain your project in 2 minutes**

**Answer:**

"I built a Finance Dashboard API using ASP.NET Core 10 and PostgreSQL. It's a backend system for managing personal financial records - tracking income and expenses.

**Architecture:**  
The project follows a three-tier layered architecture with Controllers, Services, and Repositories. This ensures clear separation of concerns and makes the code maintainable and testable.

**Key Features:**

1. **User Management** - Create, update, and delete users with role assignment
2. **Financial Records** - Track income and expenses with categorization
3. **Dashboard** - Calculate total income, expenses, and net balance
4. **Authentication** - JWT token-based authentication for security
5. **Authorization** - Role-based access control with three roles: Admin, Analyst, and Viewer
6. **Soft Delete** - Records are never permanently deleted for data safety

**Tech Stack:**  
ASP.NET Core 10, PostgreSQL, Entity Framework Core 10, JWT, BCrypt for password hashing, and Swagger for API documentation.

**Design Patterns:**  
I implemented Dependency Injection throughout, used the Repository Pattern for data access, and applied clean architecture principles.

**What I Learned:**  
This project taught me RESTful API design, authentication and authorization, database management with PostgreSQL, the importance of clean architecture, and .NET best practices.

The API is production-ready with proper error handling, input validation, and security measures."

---

### **Q2: What is the difference between Authentication and Authorization?**

**Answer:**

| Aspect | Authentication | Authorization |
|--------|---------------|---------------|
| **Definition** | Verifying identity | Verifying permissions |
| **Question** | Who are you? | What can you do? |
| **When** | During login | After authentication |
| **Example** | Username/password | Role-based access |
| **In My Project** | JWT token validation | `[Authorize(Roles = "Admin")]` |

**Example Flow:**
```
1. User logs in with username/password → Authentication
2. System verifies credentials → Authentication Success
3. System issues JWT token → Authentication Complete
4. User tries to access /api/users → Authorization Check
5. System checks if user role is 'Admin' → Authorization
6. If Admin: Access Granted, else: 403 Forbidden
```

"In my project, authentication happens through JWT tokens in the Authorization header, and authorization is handled by ASP.NET Core's `[Authorize]` attribute with role requirements."

---

### **Q3: Why did you choose PostgreSQL over SQL Server?**

**Answer:**

"I chose PostgreSQL for several strategic reasons:

1. **Open Source & Free** - No licensing costs, great for learning and production

2. **Cross-Platform** - Runs on Windows, Linux, and macOS, making deployment flexible

3. **Industry Standard** - Widely used in modern cloud applications (AWS RDS, Google Cloud SQL)

4. **Performance** - Excellent performance with large datasets and complex queries

5. **JSON Support** - Native support for JSON data types, useful for future features

6. **Learning Opportunity** - PostgreSQL is valuable skill for modern development

7. **Cloud-Ready** - Easy to deploy on AWS RDS or Azure Database for PostgreSQL

8. **Strong Community** - Excellent documentation and community support

While SQL Server is also excellent, PostgreSQL aligned better with my goals of learning cloud-native technologies and building skills relevant to modern development practices."

---

### **Q4: What is Soft Delete and why did you implement it?**

**Answer:**

"Soft delete means marking records as deleted rather than physically removing them from the database.

**Implementation:**
```csharp
public class FinancialRecord
{
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
}

// Soft delete - don't remove from database
public void Delete(int id)
{
    var record = _repository.GetById(id);
    record.IsDeleted = true;
    record.DeletedAt = DateTime.UtcNow;
    _repository.Update(record); // Update, not Delete
}

// Global query filter - automatically excludes deleted records
modelBuilder.Entity<FinancialRecord>()
    .HasQueryFilter(e => !e.IsDeleted);
```

**Benefits:**

1. **Data Recovery** - Can restore accidentally deleted records
2. **Audit Trail** - Maintain complete history of all transactions
3. **Compliance** - Some regulations require data retention
4. **Referential Integrity** - No broken foreign key relationships
5. **Analytics** - Can analyze deleted records for insights

**How It Works:**  
When querying financial records, EF Core automatically adds `WHERE IsDeleted = false` to all queries due to the global query filter. The data stays in the database but is invisible to normal queries.

If needed, we can still access deleted records by explicitly removing the filter for admin purposes."

---

### **Q5: How do you handle errors in your API?**

**Answer:**

"I implement centralized error handling using custom middleware:

```csharp
public class ErrorHandlingMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context); // Execute request pipeline
        }
        catch (KeyNotFoundException ex)
        {
            // Resource not found
            context.Response.StatusCode = 404;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Not Found", 
                message = ex.Message 
            });
        }
        catch (ArgumentException ex)
        {
            // Invalid input
            context.Response.StatusCode = 400;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Bad Request", 
                message = ex.Message 
            });
        }
        catch (UnauthorizedAccessException ex)
        {
            // No permission
            context.Response.StatusCode = 403;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Forbidden", 
                message = ex.Message 
            });
        }
        catch (Exception ex)
        {
            // Unexpected error
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Internal Server Error", 
                message = "An unexpected error occurred" 
            });
        }
    }
}
```

**Benefits:**

1. **Centralized** - All error handling in one place
2. **Consistent** - All errors return same JSON structure
3. **Clean Code** - No try-catch blocks in every controller
4. **HTTP Standards** - Proper status codes (404, 400, 500)
5. **Security** - Hides internal error details from clients

This approach keeps controllers clean and ensures consistent error responses across the entire API."

---

### **Q6: What is the difference between Scoped, Transient, and Singleton?**

**Answer:**

| Lifetime | When Created | Lifespan | Use Case |
|----------|-------------|----------|----------|
| **Transient** | Every time requested | Very short | Lightweight, stateless |
| **Scoped** | Once per HTTP request | Request lifetime | DbContext, Repositories |
| **Singleton** | Once on app start | Application lifetime | Configuration, Caching |

**Visual Example:**

```csharp
// Request 1
UserController (new) 
    → UserService (new) 
        → UserRepository (new) 
            → DbContext (new)
            
// Request 2 (new HTTP request)
UserController (new) 
    → UserService (new) 
        → UserRepository (new) 
            → DbContext (new) // New instance for new request

// BUT Singleton:
JwtHelper (same instance reused) // Created once on startup
```

**In My Project:**

```csharp
// Scoped - New instance per request
// WHY: DbContext tracks changes, needs to be fresh per request
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddDbContext<AppDbContext>(); // Always Scoped

// Singleton - One instance for all requests
// WHY: JwtHelper is stateless, no reason to recreate it
builder.Services.AddSingleton<JwtHelper>();
```

**Why DbContext is Scoped:**  
"DbContext maintains a change tracker and manages entity state. If it was Singleton, multiple requests would share the same context, causing threading issues and data conflicts. Scoped ensures each request gets its own isolated DbContext."

---

## 10. Project Explanation

### **30-Second Elevator Pitch:**

"I built a Finance Dashboard API that allows users to track their income and expenses. It features JWT authentication, role-based authorization with three user roles, and a clean three-tier architecture. The backend is built with ASP.NET Core 10 and PostgreSQL, following best practices like Dependency Injection and the Repository Pattern."

---

### **2-Minute Detailed Explanation:**

"I developed a RESTful API for managing personal finances using ASP.NET Core 10 and PostgreSQL.

**Business Purpose:**  
Users can track financial transactions—income and expenses—categorized by type (salary, rent, food, etc.). There's also a dashboard showing total income, total expenses, and net balance.

**Technical Architecture:**  
The project follows a clean three-tier architecture:
- Controllers handle HTTP requests
- Services contain business logic and validation
- Repositories manage database operations
- This separation makes the code testable and maintainable

**Security:**  
I implemented JWT token-based authentication. When users log in, they receive a token containing their ID, username, and role. This token must be included in subsequent requests.

For authorization, I use role-based access control with three roles:
- Admin: Full access to users and records
- Analyst: Can manage financial records
- Viewer: Read-only access

Passwords are hashed using BCrypt with a cost factor of 11, so plain passwords are never stored.

**Key Design Decisions:**

1. **Dependency Injection** - All services are injected via constructors, promoting loose coupling

2. **Repository Pattern** - Abstracts database operations, making it easy to test and potentially switch databases

3. **Soft Delete** - Financial records are never permanently deleted, just marked as deleted for data safety and audit trails

4. **DTOs** - Use Data Transfer Objects to hide sensitive data like password hashes from API responses

5. **Global Error Handling** - Custom middleware catches all exceptions and returns consistent error responses

**Technologies:**  
ASP.NET Core 10, PostgreSQL, Entity Framework Core 10, Npgsql for PostgreSQL connectivity, JWT for authentication, BCrypt for password hashing, and Swagger for API documentation.

**What I Learned:**  
This project taught me RESTful API design, authentication and authorization patterns, working with PostgreSQL, implementing clean architecture, and applying SOLID principles in a real-world application."

---

## 11. Technical Terms Glossary

| Term | Definition |
|------|------------|
| **API** | Application Programming Interface - allows systems to communicate |
| **REST** | Representational State Transfer - architectural style using HTTP methods |
| **JWT** | JSON Web Token - secure token for authentication |
| **ORM** | Object-Relational Mapper - maps database to objects |
| **CRUD** | Create, Read, Update, Delete - basic database operations |
| **DI** | Dependency Injection - providing dependencies externally |
| **DTO** | Data Transfer Object - simple class for transferring data |
| **Middleware** | Component that processes HTTP requests in a pipeline |
| **Scoped** | DI lifetime - one instance per HTTP request |
| **Singleton** | DI lifetime - one instance for application |
| **Transient** | DI lifetime - new instance every time |
| **DbContext** | EF Core class representing database session |
| **Repository** | Pattern abstracting data access logic |
| **RBAC** | Role-Based Access Control - permissions based on roles |
| **Soft Delete** | Marking records as deleted instead of removing |
| **BCrypt** | Password hashing algorithm |
| **LINQ** | Language Integrated Query - query syntax in C# |
| **Migration** | Database schema versioning and updates |

---

## 12. Practice Questions

### **Test yourself with these questions:**

1. What is Dependency Injection and what are its benefits?
2. Explain the three DI lifetimes with examples
3. What is the Repository Pattern and why use it?
4. Describe the architecture of your project
5. How does JWT authentication work?
6. What's the difference between Authentication and Authorization?
7. Why did you choose PostgreSQL?
8. What is Entity Framework Core?
9. Explain Database-First vs Code-First
10. What are DTOs and why use them?
11. How do you handle errors in your API?
12. What is soft delete and its benefits?
13. What is middleware and how did you use it?
14. Explain role-based authorization
15. What is DbContext and its lifetime?

---

## 13. Communication Tips for Interviews

### **DO's:**

✅ **Be Confident**  
- "I implemented this feature..."
- "I chose this approach because..."
- Speak with conviction about your decisions

✅ **Use Examples**  
- "For example, in my UsersController..."
- "Let me show you how this works in my code..."
- Concrete examples demonstrate understanding

✅ **Explain Your Thinking**  
- "I chose PostgreSQL because..."
- "I implemented soft delete to ensure..."
- Show your decision-making process

✅ **Ask Clarifying Questions**  
- "Do you want me to explain the technical implementation or the business logic?"
- Shows you think before answering

✅ **Admit What You Don't Know**  
- "I haven't implemented that feature yet, but I understand the concept is..."
- "That's an interesting question. Here's my understanding..."
- Honesty is better than making things up

### **DON'Ts:**

❌ **Don't Memorize Blindly**  
- Understand concepts, don't just memorize answers
- Interviewers can tell when you're reciting

❌ **Don't Over-Complicate**  
- Keep explanations simple and clear
- Technical jargon doesn't impress if you can't explain it

❌ **Don't Say "I Think" Too Much**  
- "I implemented..." instead of "I think I implemented..."
- Show confidence in what you've done

❌ **Don't Bad-Mouth Technologies**  
- Never say "SQL Server is bad"
- Say "I chose PostgreSQL because it fit my needs better"

---

## 14. Body Language & Presentation

### **In-Person Interviews:**

- Maintain eye contact
- Sit up straight
- Use hand gestures when explaining architecture
- Draw diagrams if allowed (whiteboard/paper)
- Smile and show enthusiasm

### **Virtual Interviews:**

- Look at the camera, not the screen
- Ensure good lighting
- Minimize background distractions
- Test audio/video beforehand
- Have your project open to share screen if asked

---

## 15. Final Checklist

### **Day Before Interview:**

- [ ] Read through this guide completely
- [ ] Practice explaining your project in 2 minutes
- [ ] Review Dependency Injection thoroughly
- [ ] Understand JWT flow
- [ ] Review architecture diagram
- [ ] Prepare 2-3 questions to ask the interviewer
- [ ] Test your API and verify it's running
- [ ] Have GitHub link ready

### **Day of Interview:**

- [ ] Review key concepts (DI, Repository Pattern, JWT)
- [ ] Be ready to explain architecture
- [ ] Have your project ready to demo
- [ ] Be confident and honest
- [ ] Listen carefully to questions
- [ ] Take a moment to think before answering

---

## 16. Sample Interview Scenario

**Interviewer:** "Tell me about your recent project."

**You:** "I built a Finance Dashboard API using ASP.NET Core 10 and PostgreSQL. It's a backend system for tracking income and expenses with JWT authentication and role-based authorization. The architecture follows clean separation with Controllers, Services, and Repositories."

**Interviewer:** "What is Dependency Injection?"

**You:** "Dependency Injection is a design pattern where a class receives its dependencies through constructor parameters rather than creating them itself. In my project, I inject services into controllers. For example, my UsersController receives IUserService through its constructor, and ASP.NET Core's DI container automatically provides the implementation. This promotes loose coupling and makes testing easier."

**Interviewer:** "Why did you use the Repository Pattern?"

**You:** "I used the Repository Pattern to abstract data access logic. Instead of controllers directly accessing the database, they use repository interfaces. This provides several benefits: it separates data logic from business logic, makes services easier to test with mock repositories, and allows me to potentially change the database implementation without affecting the rest of the code."

**Interviewer:** "How does authentication work in your API?"

**You:** "I use JWT token-based authentication. When a user logs in with username and password, I verify the password using BCrypt. If valid, I generate a JWT token containing the user's ID, username, and role as claims. The token expires in 60 minutes. For subsequent requests, the client includes this token in the Authorization header, and my authentication middleware validates it before allowing access to protected endpoints."

---

## Conclusion

This guide covers all the essential concepts you need to confidently explain your project in an interview. Remember:

1. **Understand, Don't Memorize** - Grasp the concepts deeply
2. **Be Confident** - You built this project, own it!
3. **Use Examples** - Reference your actual code
4. **Be Honest** - It's okay to say "I don't know" and explain how you'd learn
5. **Show Enthusiasm** - Talk about what you enjoyed and learned

**You're ready for your interview! Good luck! 🚀**

---

*Remember: The fact that you built this project puts you ahead of many candidates. Be proud of your work and explain it with confidence!*
