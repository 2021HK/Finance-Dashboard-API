using FinanceDashboardAPI.DTOs;
using FinanceDashboardAPI.Models;
using FinanceDashboardAPI.Constants;
using FinanceDashboardAPI.Repositories;


namespace FinanceDashboardAPI.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;

        public UserService(IUserRepository userRepository) {
            _userRepository = userRepository;
        }

        public List<UserDto> GetAll()
        {
            return _userRepository.GetAll().Select(u => new UserDto {
                Id = u.Id,
                Username = u.Username,
                Role = u.Role,
                IsActive = u.IsActive,
            }).ToList();
        }

        public UserDto GetById(int id)
        {
            var user = _userRepository.GetById(id);
            if (user == null)
                throw new
                     KeyNotFoundException("User not found");

            return new UserDto {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                IsActive = user.IsActive
            };
        }

        public UserDto Create(CreateUserDto dto)
        {
            if (!Roles.IsValid(dto.Role))
                throw new ArgumentException("Invalid role");

            if (_userRepository.Exists(dto.Username))
                throw new InvalidOperationException("Username already exists");

            var user = new User
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = dto.Role
            };

            _userRepository.Add(user);

            return new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                IsActive = user.IsActive
            };
        }

        public void Update(int id, UpdateUserDto dto)
        {
            var user = _userRepository.GetById(id);
            if (user == null)
                throw new KeyNotFoundException("User not found");

            if (!string.IsNullOrEmpty(dto.Role))
            {
                if (!Roles.IsValid(dto.Role))
                    throw new ArgumentException("Invalid role");
                user.Role = dto.Role;
            }

            if (dto.IsActive.HasValue)
             {
                user.IsActive = dto.IsActive.Value;
            }
           

            _userRepository.Update(user);
        }

        public void Delete(int id)
        {
            var user = _userRepository.GetById(id);
            if (user == null)
                throw new KeyNotFoundException("User not found");

            _userRepository.Delete(user);
        }
    } 
}

