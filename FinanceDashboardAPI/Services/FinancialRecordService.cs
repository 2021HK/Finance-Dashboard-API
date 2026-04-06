using FinanceDashboardAPI.Constants;
using FinanceDashboardAPI.DTOs;
using FinanceDashboardAPI.Models;
using FinanceDashboardAPI.Repositories;

namespace FinanceDashboardAPI.Services
{
    public class FinancialRecordService : IFinancialRecordService
    {
        private readonly IFinancialRecordRepository _repository;

        public FinancialRecordService(IFinancialRecordRepository repository)
        {
            _repository = repository;
        }

        public List<FinancialRecordDto> GetAll(int? userId = null)
        {
            var records = userId.HasValue
                ? _repository.GetByUserId(userId.Value)
                : _repository.GetAll();

            return records.Select(r => new FinancialRecordDto
            {
                Id = r.Id,
                UserId = r.UserId,
                Amount = r.Amount,
                Type = r.Type,
                Date = r.Date,
                Category = r.Category,
                Notes = r.Notes,
            }).ToList();
        }

        public FinancialRecordDto GetById(int id)
        {
            var record = _repository.GetById(id);
            if (record == null)
                throw new KeyNotFoundException("Financial record not found");

            return new FinancialRecordDto
            {
                Id = record.Id,
                UserId = record.UserId,
                Amount = record.Amount,
                Type = record.Type,
                Date = record.Date,
                Category = record.Category,
                Notes = record.Notes,
            };
        }

        public FinancialRecordDto Create(int userId, CreateRecordDto dto)
        {
            if (!TransactionTypes.IsValid(dto.Type))
                throw new ArgumentException("Invalid transaction type");
            var record = new FinancialRecord
            {
                UserId = userId,
                Amount = dto.Amount,
                Type = dto.Type,
                Date = dto.Date,
                Category = dto.Category,
                Notes = dto.Notes,
            };
            _repository.Add(record);
             

            return new FinancialRecordDto
            {
                Id = record.Id,
                UserId = record.UserId,
                Amount = record.Amount,
                Type = record.Type,
                Date = record.Date,
                Category = record.Category,
                Notes = record.Notes,
            };
        }
        public void Update(int id, CreateRecordDto dto)
        {
            var record = _repository.GetById(id);
            if (record == null)
                throw new KeyNotFoundException("Financial record not found");

            if (!TransactionTypes.IsValid(dto.Type))
                throw new ArgumentException("Invalid transaction type");

            record.Amount = dto.Amount;
            record.Type = dto.Type;
            record.Category = dto.Category;
            record.Date = dto.Date;
            record.Notes = dto.Notes;

            _repository.Update(record);
            
        }

        public void Delete(int id)
        {
            var record = _repository.GetById(id);
            if (record == null)
                throw new KeyNotFoundException("Financial record not found");

            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;

            _repository.Update(record);
            
        }
    }
}
