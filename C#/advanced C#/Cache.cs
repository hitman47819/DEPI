using System;
using System.Collections.Generic;
using System.Linq;

public class Cache<TKey, TValue> where TKey : notnull
{
    private class CacheItem
    {
        public TValue Value { get; }
        public DateTime Expiry { get; }

        public CacheItem(TValue value, TimeSpan ttl)
        {
            Value = value;
            Expiry = DateTime.Now.Add(ttl);
        }

        public bool IsExpired => DateTime.Now > Expiry;
    }

    private readonly Dictionary<TKey, CacheItem> data = new();

    public TValue this[TKey key]
    {
        get
        {
            if (!data.ContainsKey(key) || data[key].IsExpired)
            {
                data.Remove(key);
                throw new KeyNotFoundException($"Key '{key}' not found or expired.");
            }
            return data[key].Value;
        }
        set
        {
            AddOrUpdate(key, value, TimeSpan.FromMinutes(5)); 
        }
    }


    public void Add(TKey key, TValue value, TimeSpan ttl)
    {
        if (key == null) throw new ArgumentNullException(nameof(key));
        if (value == null) throw new ArgumentNullException(nameof(value));
        if (data.ContainsKey(key) && !data[key].IsExpired)
            throw new ArgumentException($"Key '{key}' already exists.");

        data[key] = new CacheItem(value, ttl);
    }


    public void AddOrUpdate(TKey key, TValue value, TimeSpan ttl)
    {
        if (key == null) throw new ArgumentNullException(nameof(key));
        if (value == null) throw new ArgumentNullException(nameof(value));
        data[key] = new CacheItem(value, ttl);
    }


    public void Remove(TKey key)
    {
        if (!data.ContainsKey(key))
            throw new KeyNotFoundException($"Key '{key}' not found.");
        data.Remove(key);
    }

    public bool TryGetValue(TKey key, out TValue value)
    {
        if (data.TryGetValue(key, out var item))
        {
            if (item.IsExpired)
            {
                data.Remove(key);
                value = default!;
                return false;
            }
            value = item.Value;
            return true;
        }
        value = default!;
        return false;
    }

    public void CleanExpired()
    {
        var expiredKeys = data.Where(kvp => kvp.Value.IsExpired).Select(kvp => kvp.Key).ToList();
        foreach (var key in expiredKeys)
            data.Remove(key);
    }

    public int Count => data.Count(kvp => !kvp.Value.IsExpired);
}
