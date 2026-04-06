using FinanceDashboardAPI.Middleware;
using Microsoft.AspNetCore.Http;
using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;


namespace FinanceDashboardAPI.Middleware
{
    public class ErrorHandlingMiddleware
    {
        private readonly RequestDelegate _next;

        public ErrorHandlingMiddleware(RequestDelegate next)
        {
            _next = next;
        }
        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);

            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private Task HandleExceptionAsync(HttpContext context , Exception exception)
        {
            var statusCode = HttpStatusCode.InternalServerError;    

            var massage = "An unexpected error occurred";

            switch (exception)
            {
                case KeyNotFoundException:
                    statusCode = HttpStatusCode.NotFound;
                    massage = exception.Message;
                    break;

                case UnauthorizedAccessException:
                    statusCode = HttpStatusCode.Unauthorized;
                    massage = exception.Message;
                    break;

                case ArgumentException:
                    case InvalidOperationException:
                    statusCode = HttpStatusCode.BadRequest;
                    massage = exception.Message;
                    break;
            }

            var response = new
            {
                error = massage,
                statusCode = (int)statusCode,
            };

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)statusCode;

            return context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}
