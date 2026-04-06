using FinanceDashboardAPI.Constants;
using FinanceDashboardAPI.DTOs;

namespace FinanceDashboardAPI.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly IFinancialRecordService _repository;

        public DashboardService(IFinancialRecordService repository)
        {
            _repository = repository;
        }

        public DashboardSummaryDto GetSummary(int? userid = null)
        {
            var records = _repository.GetAll(userid);
               

            var income = records.Where(r => r.Type == "Income").Sum(r => r.Amount);
            var expense = records.Where(r => r.Type == "Expense").Sum(r => r.Amount);

            return new DashboardSummaryDto
            {
                TotalIncome = income,
                TotalExpense = expense,
                NetBalance = income - expense,
                TotalTransactions = records.Count
            };
        }
    }
}
