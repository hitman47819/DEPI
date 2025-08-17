using System;
using System.Net;
using System.Reflection.Metadata.Ecma335;

public class BankAccount
{
    public const string BankCode = "BNK001";
    public readonly DateTime createdDate; 
    private static int allAccountsNumber = 1;
    private int accountNumber;
    private string fullName;
    private string nationalID;
    private string phoneNumber;
    private string address;
    private decimal balance;

    public int AccountNumber => accountNumber;
    public DateTime CreatedDate => createdDate; 

    public string FullName
    {
        get { return fullName; }
        private set
        {
            if (string.IsNullOrEmpty(value))
                throw new ArgumentException("Full name cannot be null or empty.");
            fullName = value;
        }
    }

    public decimal Balance
    {
        get { return balance; }
        protected set
        {
            if (value < 0)
                throw new ArgumentException("You cannot enter a negative balance.");
            balance = value;
        }
    }

    public string Address
    {
        get { return address; }
        set { address = value; }
    }

    public string PhoneNumber
    {
        get { return phoneNumber; }
        private set
        {
            if (IsValidPhoneNumber(value))
                phoneNumber = value;
            else
                throw new ArgumentException("The phone number must be 11 digits and start with 01.");
        }
    }

    public string NationalID
    {
        get { return nationalID; }
        private set
        {
            if (IsValidNationalID(value))
                nationalID = value;
            else
                throw new ArgumentException("The ID should be 14 digits.");
        }
    }

    public BankAccount()
    {
        accountNumber = allAccountsNumber++;
        FullName = "John Doe";
        NationalID = "00000000000000";
        PhoneNumber = "01000000000";
        Address = "Default Address";
        Balance = 0;
        createdDate = DateTime.Now; 
    }

    public BankAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance)
    {
        accountNumber = allAccountsNumber++;
        FullName = fullName;
        NationalID = nationalID;
        PhoneNumber = phoneNumber;
        Address = address;
        Balance = balance;
        createdDate = DateTime.Now; 
    }

    public BankAccount(string fullName, string nationalID, string phoneNumber, string address)
        : this(fullName, nationalID, phoneNumber, address, 0) { }

    public virtual decimal CalculateInterest() => 0;

    public virtual void ShowAccountDetails()
    {
        Console.WriteLine("---- Account Details ----");
        Console.WriteLine($"Bank Code: {BankCode}");
        Console.WriteLine($"Account Number: {accountNumber}");
        Console.WriteLine($"Full Name: {FullName}");
        Console.WriteLine($"National ID: {NationalID}");
        Console.WriteLine($"Phone Number: {PhoneNumber}");
        Console.WriteLine($"Address: {Address}");
        Console.WriteLine($"Balance: {Balance:C}");
        Console.WriteLine($"Created Date: {CreatedDate}");
        Console.WriteLine("-------------------------\n");
    }

    public bool IsValidNationalID(string nationalID)
    {
        return nationalID != null
            && nationalID.Length == 14
            && nationalID.All(char.IsDigit);
    }

    public bool IsValidPhoneNumber(string phoneNumber)
    {
        return phoneNumber != null
            && phoneNumber.Length == 11
            && phoneNumber.StartsWith("01")
            && phoneNumber.All(char.IsDigit);
    }

    public class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }

        public SavingAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance, decimal interestRate)
            : base(fullName, nationalID, phoneNumber, address, balance)
        {
            InterestRate = interestRate;
        }

        public override decimal CalculateInterest()
            => Balance * InterestRate / 100;

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {InterestRate}%");
            Console.WriteLine("-------------------------\n");
        }
    }

    public class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }

        public CurrentAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance, decimal overdraftLimit)
            : base(fullName, nationalID, phoneNumber, address, balance)
        {
            OverdraftLimit = overdraftLimit;
        }

        public override decimal CalculateInterest() => 0;

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverdraftLimit:C}");
            Console.WriteLine("-------------------------\n");
        }
    }
}