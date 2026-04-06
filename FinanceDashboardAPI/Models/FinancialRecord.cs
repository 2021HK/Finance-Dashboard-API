using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FinanceDashboardAPI.Models
{
    public class FinancialRecord
    {
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [Required]
        [MaxLength(10)]
        public string Type { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Category { get; set; }

        [Required]
        public DateTime Date { get; set; }

        [MaxLength(500)]
        public string Notes { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public bool IsDeleted { get; set; } = false;

        public DateTime? DeletedAt { get; set; }

        // navigation property  
        [ForeignKey("UserId")]
        public User? User { get; set; }

    }
}
