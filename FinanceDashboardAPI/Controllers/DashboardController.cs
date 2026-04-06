using FinanceDashboardAPI.Constants;
using FinanceDashboardAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FinanceDashboardAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        private int GetCurrentUserId()
        {
            return int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirst(ClaimTypes.Role)?.Value ?? "";
        }

        [HttpGet("summary")]
        [Authorize]
        public IActionResult GetSummary()
        {
            var userId = GetCurrentUserId();
            var role = GetCurrentUserRole();


            var summary = role == Roles.Viewer ? _dashboardService.GetSummary(userId)
                : _dashboardService.GetSummary();
            return Ok(summary);
        }
    }
}
