using FinanceDashboardAPI.DTOs;

namespace FinanceDashboardAPI.Services
{
    public interface IDashboardService
    {
        DashboardSummaryDto GetSummary(int? userId = null);

    }
}
