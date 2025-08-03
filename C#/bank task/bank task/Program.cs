using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
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

        // Display details
        account1.ShowAccountDetails();
        account2.ShowAccountDetails();
        Console.WriteLine("---- DefaultAccount Details ----");
        account3.ShowAccountDetails();
    }
}
