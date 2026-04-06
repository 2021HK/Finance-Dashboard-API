using FinanceDashboardAPI.Data;
using FinanceDashboardAPI.DTOs;
using FinanceDashboardAPI.Helpers;
using FinanceDashboardAPI.Models;
using System.Linq;

namespace FinanceDashboardAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly JwtHelper _jwtHelper;

        public AuthService(AppDbContext context, JwtHelper jwtHelper)
        {
            _context = context;
            _jwtHelper = jwtHelper;
        }

        public LoginResponse Login(LoginRequest request)
        {
            var user = _context.Users
                .FirstOrDefault(u => u.Username == request.Username);

            if (user == null || !user.IsActive)
                throw new UnauthorizedAccessException("Invalid credentials");

            // Verify password
            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                throw new UnauthorizedAccessException("Invalid credentials");

            var token = _jwtHelper.GenerateToken(user);

            return new LoginResponse
            {
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Username = user.Username,
                    Role = user.Role,
                    IsActive = user.IsActive
                }
            };

        }
    }
}
