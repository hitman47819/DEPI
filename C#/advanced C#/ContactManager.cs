using System;
using System.Collections.Generic;
using System.Linq;


public class Contact : IEntity
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }

    public Contact(int id, string name, string email)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty.");
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email cannot be empty.");

        Id = id;
        Name = name;
        Email = email;
    }

    public override string ToString() => $"({Id}, {Name}, {Email})";
}

public class ContactManager
{
    private readonly Repository<Contact> repository = new();

    public Contact this[int id]
    {
        get => repository.GetById(id) ?? throw new KeyNotFoundException($"Contact with Id {id} not found.");
    }

    public void AddContact(Contact contact) => repository.Add(contact);

    public Contact? GetContactById(int id) => repository.GetById(id);

    public void UpdateContact(Contact contact) => repository.Update(contact);

    public void RemoveContact(int id) => repository.Remove(id);

    public IReadOnlyList<Contact> GetAllContacts() => repository.GetAll();

    public List<Contact> SearchByName(string namePart)
    {
        if (string.IsNullOrWhiteSpace(namePart))
            return new List<Contact>();
        return repository.GetAll()
                         .Where(c => c.Name.Contains(namePart, StringComparison.OrdinalIgnoreCase))
                         .ToList();
    }
}