using HRAPI.Models;
using Microsoft.AspNetCore.Mvc;
namespace HRAPI.services
{
    public interface IEmployeeService
    {
        Task<IEnumerable<Employee>> GetAllEmployeesAsync();
        Task<Employee> GetEmployeeByIdAsync(int id);
        Task AddEmployeeAsync(Employee employee);
        Task<Employee> EditEmployeeByID(int id, Employee newEmployee);
        Task DeleteEmployeeAsync(int id);
    }
}
