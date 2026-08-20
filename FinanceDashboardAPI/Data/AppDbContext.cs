using FinanceDashboardAPI.Models;
using Microsoft.EntityFrameworkCore;


namespace FinanceDashboardAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<FinancialRecord> FinancialRecords { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Username).IsUnique();
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP"); 
            });

            // FinancialRecord configuration
            modelBuilder.Entity<FinancialRecord>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.UserId);
                entity.HasIndex(e => e.Date);
                entity.HasIndex(e => e.IsDeleted);

                entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
                entity.Property(e => e.IsDeleted).HasDefaultValue(false);

                // Foreign key relationship
                entity.HasOne(e => e.User)
                      .WithMany(u => u.FinancialRecords)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // Global query filter for soft delete
            modelBuilder.Entity<FinancialRecord>()
                .HasQueryFilter(e => !e.IsDeleted);
        }
    }
}

