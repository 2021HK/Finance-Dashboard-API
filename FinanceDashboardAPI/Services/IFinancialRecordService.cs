using FinanceDashboardAPI.DTOs;

namespace FinanceDashboardAPI.Services
{
    public interface IFinancialRecordService
    {
        List<FinancialRecordDto> GetAll(int? userId = null);
        FinancialRecordDto GetById(int id);
        FinancialRecordDto Create(int userId, CreateRecordDto dto);
        void Update(int id, CreateRecordDto dto);
        void Delete(int id);

    }
}
