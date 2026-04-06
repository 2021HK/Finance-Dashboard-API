using FinanceDashboardAPI.DTOs;

namespace FinanceDashboardAPI.Services
{
    public interface IAuthService
    {
        LoginResponse Login(LoginRequest request);
    }

}
