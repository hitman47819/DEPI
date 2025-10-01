using System;
using System.Collections.Generic;

public class ShoppingCart
{
    private readonly Dictionary<string, int> items = new();
    private readonly HashSet<string> discounts = new();

    public void AddItem(string item, int quantity = 1)
    {
        if (string.IsNullOrWhiteSpace(item))
            throw new ArgumentException("Item cannot be null or empty.", nameof(item));
        if (quantity <= 0)
            throw new ArgumentException("Quantity must be positive.", nameof(quantity));

        if (items.ContainsKey(item))
            items[item] += quantity;
        else
            items[item] = quantity;
    }

    public void RemoveItem(string item, int quantity = 1)
    {
        if (!items.ContainsKey(item))
            throw new KeyNotFoundException($"Item '{item}' not found in the cart.");
        
        items[item] -= quantity;
        if (items[item] <= 0)
            items.Remove(item);
    }

    public void ApplyDiscount(string item)
    {
        if (!items.ContainsKey(item))
            throw new KeyNotFoundException($"Item '{item}' not found in the cart.");
        discounts.Add(item);
    }

    public IReadOnlyDictionary<string, int> GetItems() => items;

    public decimal GetTotalPrice(Func<string, decimal> priceCalculator)
    {
        if (priceCalculator == null)
            throw new ArgumentNullException(nameof(priceCalculator));

        decimal total = 0;
        foreach (var kvp in items)
        {
            decimal price = priceCalculator(kvp.Key) * kvp.Value;
            if (discounts.Contains(kvp.Key))
                price *= 0.9m; // 10% discount
            total += price;
        }
        return total;
    }

    public void Clear()
    {
        items.Clear();
        discounts.Clear();
    }
}

