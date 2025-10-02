using System.ComponentModel.DataAnnotations;

namespace HRAPI.Models
{
    public class Employee
    {
        [Key]
        public int Id { get; internal set; }
        public string? Phone { get;  set; }

        [Required]
        public string FirstName { get; set; } = null!;

        [Required]
        public string LastName { get; set; } = null!;

        public string? Title { get; set; }

        [Required]
        [EmailAddress]  
        public string Email { get; set; } = null!;

        public DateTime HireDate { get; internal set; } = DateTime.UtcNow;

         public decimal Salary { get;  set; }
    }
}
