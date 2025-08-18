using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace bank_task_4
{
    public class Account
    {
        private static int idCounter = 0;

        public int AccountNumber { get; }
        public DateTime OpenTime { get; }
        public decimal Balance { get; internal set; }
        public List<Transaction> Transactions { get; set; } = new List<Transaction>();
        public string type { get; private set; }
        public DateTime LastInterestApplied { get; private set; }

        protected Account()
        {
            AccountNumber = ++idCounter;
            OpenTime = DateTime.Now;
            Balance = 0;
            Transactions = new List<Transaction>();
        }
        public class CurrentAccount : Account
        {
            public decimal OverdraftLimit { get; }
            public CurrentAccount(decimal overdraftLimit = 0)
            {
                OverdraftLimit = overdraftLimit;
                type = "CurrentAccount";

            }
        }

        public class SavingAccount : Account
        {
            public decimal InterestRate { get; }
            public SavingAccount(decimal interestRate)
            {
                InterestRate = interestRate;
                type = "SavingAccount";

            }

            public void ApplyMonthlyInterest()
            {
                if ((DateTime.Now - LastInterestApplied).TotalDays >= 30)
                {
                    decimal monthlyRate = InterestRate / 12;
                    decimal interest = Balance * monthlyRate;
                    Balance += interest;
                    Transactions.Add(new Transaction("Interest", interest, null, AccountNumber));
                    LastInterestApplied = DateTime.Now;
                }
            }
        }
    }



 
}
