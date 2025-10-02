using Microsoft.EntityFrameworkCore;

namespace EFW2
{
    public class Program
    {
        static void Main(string[] args)
        {
            var _Context = new AppDbContext();

            _Context.Database.EnsureCreated();

            _Context.SaveChanges();
        }
    }
}
