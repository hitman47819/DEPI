using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using static bank_task_4.Account;

namespace bank_task_4
{
    public class Transaction
    {
        public DateTime Date { get; }
        public string Type { get; }  
        public decimal Amount { get; }
        public int? FromAccount { get; }
        public int? ToAccount { get; }

        public Transaction(string type, decimal amount, int? fromAccount = null, int? toAccount = null)
        {
            Date = DateTime.Now;
            Type = type;
            Amount = amount;
            FromAccount = fromAccount;
            ToAccount = toAccount;
        }

        public override string ToString()
        {
            if (Type == "Transfer")
                return $"{Date}: {Type} {Amount} from {FromAccount} to {ToAccount}";
            else
                return $"{Date}: {Type} {Amount}";
        }

        public static bool Deposit(Account account, decimal amount)
        {
            if (amount <= 0)
            {
                Console.WriteLine("you CANNOT enter negative amount");
                return false;
            }
            

            account.Balance += amount;
            Console.WriteLine($"Deposit Done correctly your balance:{account.Balance}");
            account.Transactions.Add(new Transaction("Deposit", amount, null, account.AccountNumber));
            return true;
        }

        public static bool Withdraw(Account account, decimal amount)
        {
            if (amount <= 0)
            {
                Console.WriteLine("you CANNOT enter negative amount");
                return false;
            }
            if (account is CurrentAccount current)
            {
                if (account.Balance - amount < -current.OverdraftLimit)
                {
                    Console.WriteLine("Insufficient balancewith overdraft limit");
                    return false;
                }
                   
            }
            else
            {
                if (account.Balance < amount)
                {
                    Console.WriteLine("Insufficient balance");
                    return false;
                }
                   
            }

            account.Balance -= amount;
            Console.WriteLine($"Withdraw Done correctly your balance:{account.Balance}");
            account.Transactions.Add(new Transaction("Withdraw", amount, account.AccountNumber, null));
            return true;
        }

        public static bool Transfer(Account from, Account to, decimal amount)
        {
            if (amount <= 0)
            {
                Console.WriteLine("you CANNOT enter negative amount");
                return false;
            }
            if (from is CurrentAccount current)
            {
                if (from.Balance - amount < -current.OverdraftLimit)
                {
                    Console.WriteLine("Insufficient balancewith overdraft limit");
                    return false;
                }

            }
            else
            {
                if (from.Balance < amount)
                {
                    Console.WriteLine("Insufficient balance");
                    return false;
                }

            }
            from.Balance -= amount;
            to.Balance += amount;
            Console.WriteLine($"transaction Done correctly your balance:{from.Balance}");

            from.Transactions.Add(new Transaction("Transfer", amount, from.AccountNumber, to.AccountNumber));
            to.Transactions.Add(new Transaction("Transfer", amount, from.AccountNumber, to.AccountNumber));
            return true;
        }

    }
}

