using FinanceDashboardAPI.Data;
using FinanceDashboardAPI.Models;
using System.Linq;

namespace FinanceDashboardAPI.Repositories
{
    public class FinancialRecordRepository : IFinancialRecordRepository
    {
        private readonly AppDbContext _context;

        public FinancialRecordRepository(AppDbContext context)
        {
            _context = context;
        }

        public List<FinancialRecord> GetAll()
        {
            return _context.FinancialRecords.ToList();
        }

        public List<FinancialRecord> GetByUserId(int userId)
        {
            return _context.FinancialRecords
                .Where(r => r.UserId == userId)
                .ToList();
        }   

        public FinancialRecord GetById(int id)
        {
            return _context.FinancialRecords.Find(id);
        }

        public void Add(FinancialRecord record)
        {
            _context.FinancialRecords.Add(record);
            _context.SaveChanges();
        }

        public void Update(FinancialRecord record)
        {
            _context.FinancialRecords.Update(record);
            _context.SaveChanges();
        }

        public void Save()
        {
            _context.SaveChanges();
        }

    }
}
