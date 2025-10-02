using HRAPI.DATA;
using HRAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HRAPI.services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly AppDbContext _context;

        public EmployeeService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Employee>> GetAllEmployeesAsync()
        {
            return await _context.Employees.ToListAsync();
        }

        public async Task<Employee> GetEmployeeByIdAsync(int id)
        {
            return await _context.Employees.FirstOrDefaultAsync(e => e.Id == id);
        }

        public async Task AddEmployeeAsync(Employee employee)
        {
            _context.Employees.Add(employee);
            await _context.SaveChangesAsync();
        }

        public async Task<Employee> EditEmployeeByID(int id, Employee newEmployee)
        {
            var existingEmployee = await _context.Employees.FirstOrDefaultAsync(e => e.Id == id);

            if (existingEmployee != null)
            {
                existingEmployee.FirstName = newEmployee.FirstName;
                existingEmployee.LastName = newEmployee.LastName;
                existingEmployee.Email = newEmployee.Email;
                existingEmployee.Phone = newEmployee.Phone;
                 existingEmployee.HireDate = newEmployee.HireDate;
                existingEmployee.Title=newEmployee.Title;
                existingEmployee.Salary = newEmployee.Salary;

                await _context.SaveChangesAsync();
            }
            return existingEmployee;
        }

        public async Task DeleteEmployeeAsync(int id)
        {
            var employeeToDelete = await _context.Employees.FirstOrDefaultAsync(e => e.Id == id);

            if (employeeToDelete != null)
            {
                _context.Employees.Remove(employeeToDelete);
                await _context.SaveChangesAsync();
            }
        }
    }
}