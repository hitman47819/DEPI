using System;
using System.Collections.Generic;

public class PhoneBook
{
    private readonly Dictionary<string, string> contacts = new();

     public string this[string name]
    {
        get
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Name cannot be null or empty.");

            if (!contacts.ContainsKey(name))
                throw new KeyNotFoundException($"Contact '{name}' not found.");

            return contacts[name];
        }
        set
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Name cannot be null or empty.");

            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Phone number cannot be null or empty.");

            contacts[name] = value;
        }
    }

     public void AddContact(string name, string phone)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be null or empty.");

        if (string.IsNullOrWhiteSpace(phone))
            throw new ArgumentException("Phone number cannot be null or empty.");

        if (contacts.ContainsKey(name))
            throw new ArgumentException($"Contact '{name}' already exists.");
        if(phone.Length != 11)
            throw new ArgumentException("Phone number must be 11 digits long.");
        contacts[name] = phone;
    }

     public void RemoveContact(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be null or empty.");

        if (!contacts.ContainsKey(name))
            throw new KeyNotFoundException($"Contact '{name}' not found.");

        contacts.Remove(name);
    }

     public void UpdateContact(string name, string newPhone)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be null or empty.");

        if (string.IsNullOrWhiteSpace(newPhone))
            throw new ArgumentException("Phone number cannot be null or empty.");

        if (!contacts.ContainsKey(name))
            throw new KeyNotFoundException($"Contact '{name}' not found.");

        contacts[name] = newPhone;
    }

     public bool TryGetNumber(string name, out string? number)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            number = null;
            return false;
        }
        return contacts.TryGetValue(name, out number);
    }

     public IReadOnlyDictionary<string, string> GetAllContacts()
    {
        return new Dictionary<string, string>(contacts);
    }
}
