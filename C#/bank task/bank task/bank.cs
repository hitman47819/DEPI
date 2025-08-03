using System;
using System.Net;
using System.Reflection.Metadata.Ecma335;

public class BankAccount
{
    public const string BankCode = "BNK001";
    public readonly DateTime createdDate;
    private static int allacountsnumber = 1;
    private int accountNumber;
    private string fullName;
    private string nationalID;
    private string phoneNumber;
    private string address;
    private decimal balance;
    public int AccountNumber => accountNumber;
    public DateTime CreatedDate { get; }

    public string FullName
    {
        get { return fullName; }
        private set {
            if (string.IsNullOrEmpty(value))
            {
                throw new ArgumentException("Full name cannot be null or empty.");
            }
            fullName = value;
        } 
    }
     public decimal Balance  {
         get { return balance; }
        private set {
            if (value < 0) { 
            throw new ArgumentException("you can'ot enter negative ballance");
            }
            balance = value;

        }
    }
    public string Address
    {
        get { return address; }
        set { address = value; }
    }
    public string PhoneNumber{  get { return phoneNumber; }
        private set {
         if (IsValidPhoneNumber(value))
            {
                phoneNumber = value;

            }
            else
            {
                throw new ArgumentException("the phone number must be 11 digits and start with 01");
            }
        } 
    }
     public string NationalID{  get { return nationalID; }
        private set {
            if (IsValidNationalID(value))
            {
                nationalID = value;
            }
            else {
                throw new ArgumentException("the id should be 14 digits");
            }

        } 
    }
 


    public BankAccount()
    {
        accountNumber= allacountsnumber++;
        FullName = "John Doe";
        NationalID = "00000000000000";
        PhoneNumber = "01000000000";
        Address = "Default Address";
        Balance = 0;
        CreatedDate = DateTime.Now;
    }

    public BankAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance)
    {
        accountNumber= allacountsnumber++;
        FullName = fullName;
        NationalID = nationalID;
        PhoneNumber = phoneNumber;
        Address = address;
        Balance = balance;
        CreatedDate = DateTime.Now;
    }

    public BankAccount(string fullName, string nationalID, string phoneNumber, string address)
        : this(fullName, nationalID, phoneNumber, address, 0) { }

    public void ShowAccountDetails()
    {
        Console.WriteLine("---- Account Details ----");
        Console.WriteLine($"Bank Code: {BankCode}");
        Console.WriteLine($"Account Number: {accountNumber}");
        Console.WriteLine($"Full Name: {FullName}");
        Console.WriteLine($"National ID: {NationalID}");
        Console.WriteLine($"Phone Number: {PhoneNumber}");
        Console.WriteLine($"Address: {Address}");
        Console.WriteLine($"Balance: {Balance:c}");
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
            && phoneNumber.StartsWith("01");
    }



}
