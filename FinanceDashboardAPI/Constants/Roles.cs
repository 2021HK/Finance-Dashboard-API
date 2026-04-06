using System.Linq;

namespace FinanceDashboardAPI.Constants
{
    public static class Roles
    {
        public const string Admin = "Admin";
        public const string Analyst = "Analyst";
        public const string Viewer = "Viewer";

        public static readonly string[] All = { Admin, Analyst, Viewer };

        public static bool IsValid(string role)
        {
            return All.Contains(role);
        }
    }

}
