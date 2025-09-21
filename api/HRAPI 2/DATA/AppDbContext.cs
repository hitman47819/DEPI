using HRAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HRAPI.DATA
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Employee> Employees => Set<Employee>();

       

       
    }
}
