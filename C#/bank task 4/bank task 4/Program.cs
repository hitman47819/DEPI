
using System.Reflection;
using System.Transactions;

namespace bank_task_4
{
    internal class Program
    {
        static void Main(string[] args)
        {
            branch branch=new branch();
            while (true)
            {
                Console.WriteLine("\nChoose an option:");
                Console.WriteLine("1. Add customer");
                Console.WriteLine("2. Find customer by ID, Name or SSN");
                Console.WriteLine("3. Manage customer accounts");
                Console.WriteLine("4. Delete customer");
                Console.WriteLine("5. Bank Report");
                Console.WriteLine("6. Exit");

                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                      
                        branch.AddCustomer();
                        break;

                    case "2":
                        Console.WriteLine("Search by: 1. Name   2. SSN");
                        string searchOpt = Console.ReadLine();
                        Console.Write("Enter value: ");
                        string value = Console.ReadLine();
                        bool found = false;

                        if (searchOpt == "1")
                            found = branch.SearchCustomers(value,true);
                   
                        else if (searchOpt == "2")
                            found = branch.SearchCustomers(value, false);

                        if (!found )
                            Console.WriteLine(" No customer found.");
                        break;

                    case "3":
                        Console.Clear();
                        Thread.Sleep(1000); 
                        Console.Write("Enter Customer ID: ");
                        if (int.TryParse(Console.ReadLine(), out int custId))
                        {
                            Customer customer = branch.Customers.FirstOrDefault(c => c.Id == custId);
                            if (customer == null)
                            {
                                Console.WriteLine(" Customer not found.");
                                break;
                            }

                                bool manageAccounts = true;
                            while (manageAccounts)
                            {
                                Console.WriteLine("\n--- Account Management ---");
                                Console.WriteLine("1. Add Account");
                                Console.WriteLine("2. Deposit");
                                Console.WriteLine("3. Withdraw");
                                Console.WriteLine("4. Transfer");
                                Console.WriteLine("5. List Accounts");
                                Console.WriteLine("6. List Transactions");
                                Console.WriteLine("7. update account");
                                Console.WriteLine("8. Back");

                                string accChoice = Console.ReadLine();

                                switch (accChoice)
                                {
                                    case "1":
                                        try
                                        {
                                            Console.WriteLine("Choose Account Type: (1) Saving  (2) Current");
                                        string type = Console.ReadLine();
                                        if (type == "1")
                                        {
                                            Console.Write("Enter Interest Rate (e.g. 0.05 = 5%): ");
                                            decimal rate = decimal.Parse(Console.ReadLine());
                                            var savingAcc = new Account.SavingAccount(rate);
                                            customer.Accounts.Add(savingAcc);
                                            Console.WriteLine($" Saving Account created (#{savingAcc.AccountNumber})");
                                        }
                                        else if (type == "2")
                                        {
                                            Console.Write("Enter Overdraft Limit: ");
                                            decimal limit = decimal.Parse(Console.ReadLine());
                                            var currentAcc = new Account.CurrentAccount(limit);
                                            customer.Accounts.Add(currentAcc);
                                            Console.WriteLine($" Current Account created (#{currentAcc.AccountNumber})");
                                        }
                                        break;
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine($"Error: {ex.Message}");
                                        
                                        break;
                                        }
                                    case "2":
                                        try
                                        {
                                            Console.Write("Enter Account Number: ");
                                        int depAcc = int.Parse(Console.ReadLine());
                                        var accDep = customer.Accounts.Find(a => a.AccountNumber == depAcc);
                                        if (accDep != null)
                                        {
                                            Console.Write("Enter Amount: ");
                                            decimal depAmt = decimal.Parse(Console.ReadLine());
                                            Transaction.Deposit(accDep, depAmt);
                                         }
                                        else Console.WriteLine(" Account not found.");
                                        break;
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine($"Error: {ex.Message}");
                                        
                                        break;
                                        }

                                    case "3":
                                        Console.Write("Enter Account Number: ");
                                        try
                                        {
                                            int wAcc = int.Parse(Console.ReadLine());
                                            var accW = customer.Accounts.Find(a => a.AccountNumber == wAcc);
                                            if (accW != null)
                                            {
                                                Console.Write("Enter Amount: ");
                                                decimal wAmt = decimal.Parse(Console.ReadLine());
                                                Transaction.Withdraw(accW, wAmt);
                                            }
                                            else Console.WriteLine(" Account not found.");
                                            break;
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine($"Error: {ex.Message}");
                                        
                                        break;
                                        }
                                        

                                    case "4":
                                        try { 
                                        Console.Write("Enter Source Account Number: ");
                                        int srcAcc = int.Parse(Console.ReadLine());
                                        Console.Write("Enter Destination Account Number: ");
                                        int destAcc = int.Parse(Console.ReadLine());
                                        Console.Write("Enter Amount: ");
                                        decimal tAmt = decimal.Parse(Console.ReadLine());

                                        Account source = null;
                                        Account destination = null;

                                        foreach (var acc in customer.Accounts)
                                            if (acc.AccountNumber == srcAcc) { source = acc; break; }

                                        foreach (var c in branch.Customers)
                                        {
                                            foreach (var acc in c.Accounts)
                                            {
                                                if (acc.AccountNumber == destAcc)
                                                {
                                                    destination = acc;
                                                    break;
                                                }
                                            }
                                            if (destination != null) break;
                                        }

                                        if (source != null && destination != null)
                                        {
                                            Transaction.Transfer(source, destination, tAmt);
                                         }
                                        else Console.WriteLine(" Invalid accounts for transfer.");
                                        break;
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine($"Error: {ex.Message}");
                                        
                                        break;
                                            }
                                    case "5":
                                        foreach (var acc in customer.Accounts)
                                            Console.WriteLine($"#{acc.AccountNumber} | Type: {acc.type} | Balance: {acc.Balance} | Opened: {acc.OpenTime}");
                                        Console.WriteLine($"   Total Balance: {customer.GetTotalBalance()}");

                                        break;

                                    case "6": 
                                        foreach (var acc in customer.Accounts)
                                        {
                                            Console.WriteLine($"\nAccount #{acc.AccountNumber} ({acc.type}) - Balance: {acc.Balance}");
                                            foreach (var tr in acc.Transactions)
                                                Console.WriteLine(tr);
                                        }
                                        Console.WriteLine($"   Total Balance: {customer.GetTotalBalance()}");

                                        break;

                                    case "7":
                                        try
                                        {
                                            DateTime newdate;
                                            Console.WriteLine($"account details:\n{customer.Name} - {customer.Ssn} - {customer.BirthDate}");
                                            Console.WriteLine("enter the new birthdate");
                                            value = Console.ReadLine();
                                            newdate = Convert.ToDateTime(value);
                                            Console.WriteLine("enter the new name");
                                            value = Console.ReadLine();

                                            customer.UpdateCustomer(value, newdate);

                                            break;
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine($"Error: {ex.Message}");
                                        
                                        break;
                                        }

                                    case "8": manageAccounts = false; break;

                                    default: Console.WriteLine(" Invalid choice."); break;
                                }
                            }
                        }
                        else Console.WriteLine(" Invalid customer ID.");
                        break;

                    case "4":
                        Console.Write("Enter Customer ID: ");
                        int delId = int.Parse(Console.ReadLine());
                        try
                        {
                            branch.DeleteCustomer(delId);
                            Console.WriteLine(" Customer deleted.");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($" {ex.Message}");
                        }
                        break;

                    case "5":
                        branch.BankReport();
                        break;

                    case "6":
                        Console.WriteLine("Goodbye!");
                        return;

                    default:
                        Console.WriteLine(" Invalid choice.");
                        break;
                }
            }
        }
    }
}
