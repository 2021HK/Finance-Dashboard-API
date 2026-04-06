using System.ComponentModel.DataAnnotations;

namespace FinanceDashboardAPI.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class CreateUserDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        
        public string Password { get; set; } = string.Empty;

        [Required]
        public string Role { get; set; } = string.Empty;
    }

    public class UpdateUserDto
    {
        public string? Role { get; set; }
        public bool? IsActive { get; set; }
    }

}
