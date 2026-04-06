using System.Linq;

namespace FinanceDashboardAPI.Constants
{
    public static class TransactionTypes
    {
        public const string Income = "Income";
        public const string Expense = "Expense";

        public static readonly string[] All = { Income, Expense };

        public static bool IsValid(string type)
        {
            return All.Contains(type);
        }
    }

}
