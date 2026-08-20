# Interview Preparation Guide - Finance Dashboard API

## For Freshers: Core Concepts Explained Simply

---

## 1. Dependency Injection (DI) - बहुत Important!

### **What is Dependency Injection?**

**Simple Definition:**  
Dependency Injection matlab ek class ko uski required objects (dependencies) **bahar se provide** karna, instead of class khud unhe create kare.

### **Real-Life Example:**

**Without DI (❌ Bad):**
```csharp
public class UsersController
{
    private UserService _userService;
    
    public UsersController()
    {
        // Controller khud service bana raha hai - TIGHT COUPLING
        _userService = new UserService();
    }
}
```
**Problem:** Agar UserService change ho, toh controller bhi change karna padega.

**With DI (✅ Good):**
```csharp
public class UsersController
{
    private readonly IUserService _userService;
    
    // Constructor injection - service bahar se mil raha hai
    public UsersController(IUserService userService)
    {
        _userService = userService;
    }
}
```
**Benefit:** Controller ko pata nahi ki actual implementation kya hai. Easy to test and change!

---

### **Interview Questions & Answers:**

**Q1: What is Dependency Injection?**

**Answer:**  
"Dependency Injection ek design pattern hai jisme ek class apni dependencies khud create nahi karti, balki constructor ya method ke through **inject** hoti hain. Isse loose coupling milti hai aur testing easier hoti hai."

**Example in my project:**  
"Mere project me `UsersController` ko `IUserService` ki zarurat hai. Main `IUserService` ko constructor me inject karta hoon, aur ASP.NET Core automatically `UserService` ka instance provide kar deta hai."

---

**Q2: Why use Dependency Injection?**

**Answer:**  
1. **Loose Coupling** - Classes ek dusre se independent hain
2. **Easy Testing** - Mock objects inject kar sakte hain
3. **Flexibility** - Implementation easily change kar sakte hain
4. **Maintainability** - Code maintain karna easy hai

**Example:**  
"Agar mujhe UserService ki jagah FakeUserService use karni hai testing ke liye, toh main sirf DI container me registration change karunga. Controller code same rahega."

---

**Q3: What are the 3 types of DI Lifetimes in ASP.NET Core?**

**Answer:**

| Lifetime | Lifetime | Example Use Case |
|----------|----------|------------------|
| **Transient** | Har baar naya instance | Lightweight services (e.g., Helpers) |
| **Scoped** | Ek request me ek instance | DbContext, Repositories |
| **Singleton** | Pura application me ek instance | Configuration, Caching |

**In my project:**
```csharp
// Scoped - Har HTTP request ke liye naya instance
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

// Singleton - Ek baar banao, sab use karenge
builder.Services.AddSingleton<JwtHelper>();
```

---

**Q4: Where do we register services in ASP.NET Core?**

**Answer:**  
"`Program.cs` file me `builder.Services` ke through services register karte hain."

**Example from my project:**
```csharp
// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IFinancialRecordRepository, FinancialRecordRepository>();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
```

---

## 2. Repository Pattern

### **What is Repository Pattern?**

**Simple Definition:**  
Repository ek layer hai jo database operations ko hide karti hai. Controller directly database ko access nahi karta, repository ke through access karta hai.

### **Why use it?**

1. **Separation of Concerns** - Data logic alag, business logic alag
2. **Easy to Test** - Mock repository bana sakte hain
3. **Centralized Data Logic** - Ek jagah pe sab data operations

### **Interview Answer:**

"Repository Pattern ek design pattern hai jo data access logic ko encapsulate karta hai. Isse application ka business logic database se independent ho jata hai."

**Example from my project:**
```csharp
// Interface
public interface IUserRepository
{
    List<User> GetAll();
    User GetById(int id);
    void Add(User user);
    void Update(User user);
}

// Implementation
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;
    
    public UserRepository(AppDbContext context)
    {
        _context = context; // DI through constructor
    }
    
    public List<User> GetAll()
    {
        return _context.Users.ToList();
    }
}
```

---

## 3. Three-Tier Architecture

### **Layers in my project:**

```
Controller → Service → Repository → Database
```

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **Controller** | HTTP requests handle karna | `UsersController.cs` |
| **Service** | Business logic | `UserService.cs` |
| **Repository** | Database operations | `UserRepository.cs` |
| **Database** | Data storage | PostgreSQL |

### **Interview Explanation:**

"Mere project me teen layers hain:

1. **Controller Layer** - API endpoints handle karta hai. User se request leke service ko deta hai.

2. **Service Layer** - Business logic hai. Jaise password validate karna, calculations karna. Service repository ko call karti hai.

3. **Repository Layer** - Database ke saath interact karta hai. CRUD operations perform karta hai.

**Example flow:**
```
User → POST /api/users → UsersController
                          ↓
                     UserService (validate, hash password)
                          ↓
                     UserRepository (save to DB)
                          ↓
                     PostgreSQL Database
```

---

## 4. JWT Authentication

### **What is JWT?**

**Simple Definition:**  
JWT (JSON Web Token) ek secure token hai jo user ki identity prove karta hai. User login karta hai, token milta hai, har request me token bhejta hai.

### **JWT Structure:**
```
Header.Payload.Signature
```

**Example JWT:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### **Interview Questions & Answers:**

**Q: How does JWT authentication work in your project?**

**Answer:**

"Mere project me JWT authentication 3 steps me kaam karta hai:

**Step 1: Login**
```csharp
POST /api/auth/login
{
  "username": "admin",
  "password": "Admin@123"
}
```
- Password BCrypt se verify hota hai
- Agar correct hai, toh JWT token generate hota hai
- Token me user ka Id, Username, aur Role hota hai

**Step 2: Token Generate**
```csharp
public string GenerateToken(User user)
{
    var claims = new[]
    {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Name, user.Username),
        new Claim(ClaimTypes.Role, user.Role)
    };
    
    // Token 60 minutes ke liye valid
    Expires = DateTime.UtcNow.AddMinutes(60);
}
```

**Step 3: Use Token**
```http
GET /api/users
Authorization: Bearer eyJhbGciOiJI...
```
- Middleware token validate karti hai
- Claims se user information milti hai
- Role check hota hai authorization ke liye

---

## 5. Entity Framework Core

### **What is EF Core?**

**Simple Definition:**  
Entity Framework Core ek ORM (Object-Relational Mapper) hai. Matlab C# objects se directly database operations kar sakte hain, SQL queries likhne ki zarurat nahi.

### **Interview Answer:**

"EF Core ek ORM tool hai jo C# classes ko database tables me map karta hai. Hume raw SQL queries likhne ki zarurat nahi padti."

**Example:**
```csharp
// Without EF Core - SQL query
string sql = "SELECT * FROM Users WHERE Id = @id";

// With EF Core - LINQ
var user = _context.Users.Find(id);
```

### **Database-First vs Code-First:**

**Code-First (❌ Not used in my project):**
- C# models pehle banao
- EF Core migrations se database create karo

**Database-First (✅ Used in my project):**
- PostgreSQL me pehle tables banao
- `dotnet ef dbcontext scaffold` se C# models generate karo

**Why I used Database-First:**  
"Maine Database-First approach use ki kyunki:
1. Database design pehle finalize thi
2. SQL scripts me schema clear tha
3. DBA control rakh sakte hain database pe"

---

## 6. Role-Based Authorization (RBAC)

### **What is RBAC?**

**Simple Definition:**  
Different users ko different permissions dena based on their role.

### **Roles in my project:**

| Role | Can Do |
|------|--------|
| **Admin** | Everything - manage users + records |
| **Analyst** | Manage financial records only |
| **Viewer** | Only view records, cannot modify |

### **Implementation:**

```csharp
[Authorize(Roles = Roles.Admin)] // Only Admin
public class UsersController : ControllerBase
{
    // User management endpoints
}

[Authorize(Roles = "Admin,Analyst")] // Admin OR Analyst
[HttpPost]
public IActionResult CreateRecord(...)
{
    // Create financial record
}

[Authorize] // Any authenticated user
[HttpGet]
public IActionResult GetRecords(...)
{
    // View records
}
```

### **Interview Explanation:**

"Mere project me 3 roles hain - Admin, Analyst, aur Viewer. Maine `[Authorize]` attribute use kiya controllers pe. 

**Example:**  
`UsersController` pe `[Authorize(Roles = Roles.Admin)]` hai, matlab sirf Admin users access kar sakte hain. JWT token me role claim hota hai, middleware us se permission check karta hai."

---

## 7. Middleware

### **What is Middleware?**

**Simple Definition:**  
Middleware ek pipeline hai jo har HTTP request ko process karta hai before controller tak pahunchne se pehle.

### **Middleware in my project:**

```csharp
// Error Handling Middleware
app.UseMiddleware<ErrorHandlingMiddleware>();

// Authentication Middleware
app.UseAuthentication();

// Authorization Middleware
app.UseAuthorization();
```

**Order matters:**
1. Error handling sabse pehle (catch all errors)
2. Authentication (verify token)
3. Authorization (check permissions)
4. Controllers (handle request)

### **Custom Middleware Example:**

```csharp
public class ErrorHandlingMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context); // Next middleware call karo
        }
        catch (Exception ex)
        {
            // Global error handling
            context.Response.StatusCode = 500;
            await context.Response.WriteAsync("Internal Server Error");
        }
    }
}
```

---

## 8. DTOs (Data Transfer Objects)

### **What are DTOs?**

**Simple Definition:**  
DTOs simple classes hain jo data transfer karne ke liye use hote hain between layers. Database entities directly expose nahi karte.

### **Why use DTOs?**

1. **Security** - Password jaise sensitive fields hide kar sakte hain
2. **Flexibility** - Client ko sirf required data bhejo
3. **Validation** - Input validation DTOs pe lagta hai

### **Example:**

```csharp
// Model - Database entity
public class User
{
    public int Id { get; set; }
    public string Username { get; set; }
    public string PasswordHash { get; set; } // Sensitive!
    public string Role { get; set; }
}

// DTO - For API response
public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; }
    public string Role { get; set; }
    // No PasswordHash - security!
}

// DTO - For creating user
public class CreateUserDto
{
    [Required]
    public string Username { get; set; }
    
    [Required]
    [MinLength(8)]
    public string Password { get; set; } // Plain password
    
    [Required]
    public string Role { get; set; }
}
```

---

## 9. Common Interview Questions

### **Q1: Explain your project in 2 minutes**

**Answer:**

"Maine ek Finance Dashboard API banaya hai ASP.NET Core 10 aur PostgreSQL use karke. 

**Purpose:** Users apne financial records manage kar sakte hain - income aur expenses track kar sakte hain.

**Architecture:** Maine three-tier architecture follow ki hai - Controllers, Services, aur Repositories.

**Key Features:**
- JWT authentication for security
- Role-based authorization (Admin, Analyst, Viewer)
- Soft delete - data kabhi permanently delete nahi hota
- Repository pattern for clean data access
- Dependency Injection for loose coupling

**Tech Stack:** ASP.NET Core 10, PostgreSQL, EF Core, JWT, BCrypt, Swagger

**What I learned:** API design, authentication, database management, clean architecture, aur .NET best practices."

---

### **Q2: Why did you choose PostgreSQL over SQL Server?**

**Answer:**

"Maine PostgreSQL choose kiya kyunki:
1. **Open Source** - Free aur community support achhi hai
2. **Cross-platform** - Windows, Linux, Mac pe easily run hota hai
3. **Performance** - Large datasets ke liye better performance
4. **Industry Standard** - Cloud platforms (AWS RDS) me widely used hai
5. **Learning** - Future projects ke liye useful skill hai"

---

### **Q3: How do you handle errors in your API?**

**Answer:**

"Maine global error handling middleware implement kiya hai jo sab exceptions catch karta hai aur consistent error response return karta hai.

**Example:**
```csharp
public class ErrorHandlingMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
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
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new 
            { 
                error = "Server Error", 
                message = "Something went wrong" 
            });
        }
    }
}
```

Isse saare controllers me try-catch likhne ki zarurat nahi padti aur errors consistently handle hote hain."

---

### **Q4: What is the difference between Scoped and Transient?**

**Answer:**

| Lifetime | Kab naya instance banta hai | Example |
|----------|----------------------------|---------|
| **Transient** | Har baar jab request kiya | Lightweight helpers |
| **Scoped** | Ek HTTP request me ek baar | DbContext, Repositories |
| **Singleton** | Application start me ek baar | JwtHelper, Configuration |

**Example:**  
"DbContext scoped hai kyunki ek request ke andar multiple times use hota hai, but different requests ko different DbContext chahiye. JwtHelper singleton hai kyunki wo stateless hai aur ek instance sabke liye kaam kar sakta hai."

---

### **Q5: What is soft delete and why did you use it?**

**Answer:**

"Soft delete matlab data physically database se delete nahi hota, sirf ek flag (`IsDeleted = true`) set hota hai.

**Benefits:**
1. **Data Recovery** - Agar galti se delete ho jaye, recover kar sakte hain
2. **Audit Trail** - History maintain hoti hai
3. **Referential Integrity** - Foreign key constraints nahi tootte

**Implementation:**
```csharp
public class FinancialRecord
{
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
}

// Global query filter
modelBuilder.Entity<FinancialRecord>()
    .HasQueryFilter(e => !e.IsDeleted);
```

Ab jab bhi records query karenge, deleted records automatically filter ho jayenge."

---

## 10. Key Talking Points (Interview me bolne ke liye)

✅ **Strong Points:**

1. "Maine clean architecture follow kiya hai with proper separation of concerns"

2. "Security ek priority thi - JWT authentication, BCrypt password hashing, aur role-based authorization implement kiya"

3. "Dependency Injection use kiya hai jisse testing aur maintenance easy hai"

4. "Repository Pattern use kiya jo data access logic ko isolate karta hai"

5. "Global error handling middleware hai jo consistent error responses deta hai"

6. "Database-First approach use kiya jo real-world production scenarios me common hai"

7. "Soft delete implement kiya data safety ke liye"

8. "Swagger documentation hai jo API testing aur understanding me helpful hai"

---

## 11. Technical Terms to Remember

| Term | Hindi Explanation |
|------|------------------|
| **API** | Application Programming Interface - do systems ke beech communication |
| **REST** | Representational State Transfer - HTTP methods (GET, POST, PUT, DELETE) use karna |
| **JWT** | JSON Web Token - secure token for authentication |
| **ORM** | Object-Relational Mapper - database ko objects se map karna |
| **CRUD** | Create, Read, Update, Delete operations |
| **DI** | Dependency Injection - dependencies bahar se inject karna |
| **DTO** | Data Transfer Object - data transfer ke liye simple class |
| **Middleware** | Request pipeline me processing |
| **Scoped** | Ek request me ek instance |
| **Singleton** | Application me ek instance |
| **Transient** | Har request pe naya instance |

---

## 12. Practice Questions (Khud se practice karo)

1. Dependency Injection kya hai aur kyu use karte hain?
2. Repository Pattern ke kya benefits hain?
3. JWT authentication kaise kaam karta hai?
4. Scoped, Transient, aur Singleton me difference?
5. Middleware kya hota hai?
6. DTO kyu use karte hain instead of direct models?
7. Soft delete kya hai?
8. Three-tier architecture explain karo
9. Entity Framework Core kya hai?
10. Role-based authorization kaise implement kiya?

---

## 13. Body Language & Communication Tips

1. **Confident bano** - "Maine ye implement kiya hai" (not "maine try kiya tha")
2. **Examples do** - "For example, in my project..."
3. **Honest raho** - Agar kuch nahi pata, toh "I haven't implemented this yet, but I know the concept"
4. **Project proudly explain karo** - Tumne banaya hai, confidence se bolo!

---

## Good Luck! 🎯

**Remember:** Interviewer tumhare project ki complexity nahi dekh raha, wo dekh raha hai ki tum concepts ko kitna achhe se samajhte ho aur explain kar sakte ho. 

**Be confident, be clear, be yourself!** 💪
