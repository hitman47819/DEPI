using System;
using System.Collections.Generic;
using System.Linq;

public interface IEntity
{
    int Id { get; set; }
}
public class EntityPair : IEntity
{
    public int Id { get; set; }
    public string Value { get; set; }

    public EntityPair(int id, string value)
    {
        Id = id;
        Value = value;
    }

    public override string ToString() => $"({Id}, {Value})";
}

public class Repository<T> where T : IEntity
{
    private readonly List<T> items = new();

    public void Add(T entity)
    {
        if (entity == null) throw new ArgumentNullException(nameof(entity));
        if (items.Any(i => i.Id == entity.Id))
            throw new ArgumentException($"Entity with Id {entity.Id} already exists.");
        items.Add(entity);
    }

    public T? GetById(int id) => items.FirstOrDefault(i => i.Id == id);

    public void Update(T entity)
    {
        var existing = GetById(entity.Id);
        if (existing == null) throw new KeyNotFoundException($"Entity with Id {entity.Id} not found.");
        int index = items.IndexOf(existing);
        items[index] = entity;
    }

    public void Remove(int id)
    {
        var existing = GetById(id);
        if (existing == null) throw new KeyNotFoundException($"Entity with Id {id} not found.");
        items.Remove(existing);
    }

    public IReadOnlyList<T> GetAll() => items.AsReadOnly();
}
