using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace bank_task_4
{
    public class Customer
    {

        private static int idCounter = 0;

        public int Id { get; }
        public string Name { get; private set; }
        public string Ssn { get; private set; }
        public DateTime BirthDate { get; private set; }
        public List<Account> Accounts { get; set; } = new List<Account>();
        public decimal GetTotalBalance()
        {
            decimal totalBalance = 0;
            foreach (var acc in Accounts)
            {
                totalBalance += acc.Balance;
            }
            return totalBalance;
        }

        public Customer(string name, string ssn, DateTime birthdate )
        {
            if (string.IsNullOrEmpty(name))
                throw new ArgumentException("Full name cannot be null or empty.");

            if (!ValidSSN(ssn))
                throw new ArgumentException("Invalid SSN");

            Id = ++idCounter;
            Name = name;
            Ssn = ssn;
            BirthDate = birthdate;
            Accounts = new List<Account>();
        }
        public void AddAccount(Account account) => Accounts.Add(account);
        public void UpdateCustomer(string newName, DateTime newDob)
        {
            if (!string.IsNullOrEmpty(newName))
                Name = newName;
                BirthDate = newDob;
            Console.WriteLine($"the new credintials:{Name} - {Ssn} - {BirthDate} - Total balance: {GetTotalBalance()}");
        }

        public static bool ValidSSN(string nationalID)
        {
           
                return nationalID != null
                && nationalID.Length == 14
                && nationalID.All(char.IsDigit)&&nationalID[1]!='-';
        }

    }
}
