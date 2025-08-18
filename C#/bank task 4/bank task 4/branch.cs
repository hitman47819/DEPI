using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace bank_task_4
{
    public class branch
    {
        public int Id { get; private set; }
        public string Name { get; private set; }

        private List<Customer> customers;
        public List<Customer> Customers => customers;   

        public branch()
        {
            Console.WriteLine("Welcome to your bank please enter the bank name and id:");
            Name = Console.ReadLine();
            while (string.IsNullOrEmpty(Name))
            {
                Console.WriteLine("Bank name cannot be empty. Please enter a valid name:");
                Name = Console.ReadLine();
            }
            Id = Convert.ToInt32(Console.ReadLine());
            bool validId = true ;
            if (Id <= 0) validId = false;
            while (!validId)
            {
                Console.WriteLine("Please enter a positive bank ID:");
                string input = Console.ReadLine();
                if (int.TryParse(input, out int id) && id > 0)
                {
                    Id = id;
                    validId = true;
                }
                else
                {
                    Console.WriteLine("Invalid ID. Please enter a positive number.");
                }
            }
            customers = new List<Customer>();

            Console.WriteLine($"Welcome to {Name} bank \n what do you want to do:");
        }

        public void AddCustomer()
        {
            Console.WriteLine("Enter customer name:");
            string custName = Console.ReadLine();

            Console.WriteLine("Enter customer SSN (14 digits):");
            string ssn = Console.ReadLine();

            Console.WriteLine("Enter customer Birth Date:");
            string val = Console.ReadLine();

            try
            {
                foreach(Customer ust in customers) {
                    if (ust.Ssn == ssn) {
                        throw new ArgumentException ( "SSN must be unique");
                    }
                }
                Customer c = new Customer(custName, ssn, Convert.ToDateTime(val));
                customers.Add(c);
                Console.WriteLine($"Customer {c.Name} added successfully with ID {c.Id}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
        public void DeleteCustomer(int customerId)
        {
            Customer customer = null;
            foreach (var c in customers)
            {
                if (c.Id == customerId)
                {
                    customer = c;
                    break;
                }
            }
            if (customer == null) throw new InvalidOperationException("Customer not found.");

            foreach (var acc in customer.Accounts)
            {
                if (acc.Balance != 0)
                {
                    throw new InvalidOperationException("Cannot delete customer with non-zero account balances.");

                }
            }

            customers.Remove(customer);
        }
        public bool SearchCustomers(string value, bool type)
        {
            bool found = false; 

            foreach (var c in customers)
            {
                if (type && c.Name == value || !type && c.Ssn == value)
                {
                    Console.WriteLine($"{c.Id} - {c.Name} - {c.Ssn} - {c.BirthDate}");
                    found = true;
                }
            }
            return found;
        }
        public void BankReport()
        {
            Console.WriteLine($"--- Bank Report for {Name} ---");
            foreach (var c in customers)
            {
                Console.WriteLine($"Customer: {c.Name}, ID: {c.Id}, SSN: {c.Ssn}, DOB: {c.BirthDate.ToShortDateString()}");
                foreach (var acc in c.Accounts)
                {
                    Console.WriteLine($"   Account {acc.AccountNumber} ({acc.type}) - Balance: {acc.Balance}");

                }
                Console.WriteLine($"   Total Balance: {c.GetTotalBalance()}");
                Console.WriteLine();
            }
        }
        public void DeleteCustomers(string value, bool type)
        {
            for (int i = customers.Count - 1; i >= 0; i--)
            {
                var c = customers[i];
                if (type && c.Name == value || !type && c.Ssn == value)
                {
                    Console.WriteLine($"{c.Id} - {c.Name} - {c.Ssn} - {c.BirthDate}");
                    customers.RemoveAt(i);
                    Console.WriteLine("Removed");
                }
            }
        }
    }
}
