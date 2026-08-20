using FinanceDashboardAPI.Models;

namespace FinanceDashboardAPI.Repositories
{
    public interface IUserRepository
    {
        List<User> GetAll();
        User? GetById(int id);
        User? GetByUsername(string username);
        void Add(User user);
        void Update(User user);
        void Delete(User user);
        bool Exists(string username);

    }
}
