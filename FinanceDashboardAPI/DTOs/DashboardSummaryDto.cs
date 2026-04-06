namespace FinanceDashboardAPI.DTOs
{
    public class DashboardSummaryDto
    {
        public decimal TotalIncome { get; set; }
        public decimal TotalExpense { get; set; }
        public decimal NetBalance { get; set; }
        public int TotalTransactions { get; set; }
    }

}
