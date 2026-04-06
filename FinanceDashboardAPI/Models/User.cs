using System.ComponentModel.DataAnnotations;

namespace FinanceDashboardAPI.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        public string Role { get; set; }  // Default role is "User"

        public bool IsActive { get; set; } = true; 

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; 

        public DateTime? UpdatedAt { get; set; }


        // navigation 
        public ICollection<FinancialRecord> FinancialRecords { get; set; } = new List<FinancialRecord>();
    }
}
