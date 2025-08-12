using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using static BankAccount;
class Program
{
    static void Main()
    {
        BankAccount account1 = new BankAccount(
            "Alice Smith",
            "30310013412698",
            "01012345678",
            "1428 Elm Street",
            1500.75m
        );

        BankAccount account2 = new BankAccount(
            "Bob Johnson",
            "30310069413658",
            "01123456789",
            "360 Qalyub Elbalad"
        );

        BankAccount account3 = new BankAccount(); 

        SavingAccount savingAcc = new SavingAccount(
            "Charlie Brown",
            "30310088889999",
            "01234567890",
            "123 Palm Street",
            5000.00m,
            5.5m 
        );

        CurrentAccount currentAcc = new CurrentAccount(
            "Diana Prince",
            "30310077776666",
            "01555555555",
            "456 Oak Avenue",
            2000.00m,
            1000.00m 
        );

          account1.ShowAccountDetails();
        account2.ShowAccountDetails();
        Console.WriteLine("---- DefaultAccount Details ----");
        account3.ShowAccountDetails();
        Console.WriteLine("---- savingAcc Details ----");

        List<BankAccount> accounts = new List<BankAccount>
        {
            savingAcc,
            currentAcc
        };

        foreach (var acc in accounts)
        {
            acc.ShowAccountDetails();
            Console.WriteLine($"Calculated Interest: {acc.CalculateInterest():C}");
            Console.WriteLine(new string('-', 40));
        }

        Console.ReadLine();
    }
}