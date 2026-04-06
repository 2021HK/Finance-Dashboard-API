using FinanceDashboardAPI.Constants;
using FinanceDashboardAPI.DTOs;
using FinanceDashboardAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FinanceDashboardAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecordsController : ControllerBase
    {
        private readonly IFinancialRecordService _recordService;

        public RecordsController(IFinancialRecordService recordService)
        {
            _recordService = recordService;
        }

        private int GetCurrentUserId()
        {
            return int.Parse(User.FindFirst(ClaimTypes.NameIdentifier) ?.Value ?? "0");
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirst(ClaimTypes.Role)?.Value ?? "";
        }

        [HttpGet]
        [Authorize]
        public IActionResult GetAll()
        {
            var userId = GetCurrentUserId();
            var role = GetCurrentUserRole();

            var records = role == Roles.Viewer  ? _recordService.GetAll(userId) : _recordService.GetAll();
            return Ok(records);
        }

        [HttpGet("{id}")]
        [Authorize]
        public IActionResult GetById(int id)
        {
            var record = _recordService.GetById(id);
            return Ok(record);
        }

        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin },{ Roles.Analyst}")]

        public IActionResult Create([FromBody] CreateRecordDto dto)
        {
            var userId = GetCurrentUserId();
            var record = _recordService.Create(userId, dto);
            return Ok(new { message = "Financial record created successfully", record });
        }

        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Analyst}")]

        public IActionResult Update(int id, [FromBody] CreateRecordDto dto)
        {
            _recordService.Update(id, dto);
            return Ok(new { message = "Financial record updated successfully" });
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = Roles.Admin)]

        public IActionResult Delete(int id)
        {
            _recordService.Delete(id);
            return Ok(new { message = "Financial record deleted successfully" });
        }
    }
}
