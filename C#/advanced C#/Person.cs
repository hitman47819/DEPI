using System;
using System.Collections.Generic;
using System.Linq;
using System;

public class Person
{
    public string FirstName { get; set; }
    public string? MiddleName { get; set; }   
    public string LastName { get; set; }
    public DateTime? DateOfBirth { get; set; }  

    public Person(string firstName, string lastName, string? middleName = null, DateTime? dob = null)
    {
        if (string.IsNullOrWhiteSpace(firstName))
            throw new ArgumentException("First name cannot be empty.");
        if (string.IsNullOrWhiteSpace(lastName))
            throw new ArgumentException("Last name cannot be empty.");

        FirstName = firstName;
        LastName = lastName;
        MiddleName = middleName;
        DateOfBirth = dob;
    }

    public override string ToString()
    {
        string middle = string.IsNullOrWhiteSpace(MiddleName) ? "" : $" {MiddleName}";
        string dob = DateOfBirth.HasValue ? $" (DOB: {DateOfBirth.Value:yyyy-MM-dd})" : "";
        return $"{FirstName}{middle} {LastName}{dob}";
    }

    public int? GetAge()
    {
        if (!DateOfBirth.HasValue) return null;

        var today = DateTime.Today;
        int age = today.Year - DateOfBirth.Value.Year;
        if (DateOfBirth.Value.Date > today.AddYears(-age)) age--;
        return age;
    }
}
