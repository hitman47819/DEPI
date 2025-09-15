using HRAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HRAPI.DATA
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Employee> Employees => Set<Employee>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Employee>(eb =>
            {
                eb.HasKey(e => e.Id);

                eb.Property(e => e.Id)
                  .ValueGeneratedOnAdd();   

                eb.Property(e => e.FirstName).IsRequired();
                eb.Property(e => e.LastName).IsRequired();

                eb.Property(e => e.Salary)
                  .HasPrecision(18, 2);
            });
        }
    }
}
