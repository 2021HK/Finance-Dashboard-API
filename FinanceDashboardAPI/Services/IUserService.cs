using FinanceDashboardAPI.DTOs;

namespace FinanceDashboardAPI.Services
{
    public interface IUserService
    {
        List<UserDto> GetAll();
        UserDto GetById(int id);
        UserDto Create(CreateUserDto dto);
        void Update(int id, UpdateUserDto dto);
        void Delete(int id);
    }
}
