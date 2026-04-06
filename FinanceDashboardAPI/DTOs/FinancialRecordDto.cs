using System.ComponentModel.DataAnnotations;

namespace FinanceDashboardAPI.DTOs
{
    public class FinancialRecordDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string Type { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public string? Notes { get; set; }
    }

    public class CreateRecordDto
    {
        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        [RegularExpression("^(Income|Expense)$", ErrorMessage = "Type must be either 'Income' or 'Expense'")]
        public string Type { get; set; } = string.Empty;

        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string Category { get; set; } = string.Empty;

        [Required]
        public DateTime Date { get; set; }

        [StringLength(500)]
        public string? Notes { get; set; }
    }

}
