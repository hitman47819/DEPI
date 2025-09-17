using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using CompanyEFCore.Models;

namespace CompanyEFCore
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8;

            // Adjust the connection string in CompanyContext.cs (if needed)
            using var db = new CompanyContext();

            Console.WriteLine("=== Employees and Departments ===");
            var employees = db.Employees
                              .Include(e => e.DnoNavigation)
                              .Include(e => e.WorksFors)
                                  .ThenInclude(w => w.PnoNavigation)
                              .ToList();

            foreach (var e in employees)
            {
                Console.WriteLine($"Employee: {e.Fname} {e.Lname} (SSN: {e.Ssn})");
                Console.WriteLine($"  Department: {e.DnoNavigation?.Dname ?? "None"}");

                if (e.WorksFors.Any())
                {
                    Console.WriteLine("  Projects:");
                    foreach (var wf in e.WorksFors)
                    {
                        Console.WriteLine($"    - {wf.PnoNavigation.Pname} ({wf.Hours} hrs)");
                    }
                }
                else
                {
                    Console.WriteLine("  No project assignments.");
                }

                Console.WriteLine(new string('-', 40));
            }

            Console.WriteLine("Done. Press any key to exit.");
            Console.ReadKey();
        }
    }
}
