using FinanceDashboardAPI.Models;

namespace FinanceDashboardAPI.Repositories
{
    public interface IFinancialRecordRepository
    {
        List<FinancialRecord> GetAll();
        List<FinancialRecord> GetByUserId(int userId);
        FinancialRecord GetById(int id);
        void Add(FinancialRecord record);
        void Update(FinancialRecord record);
        void Save();

    }
}
