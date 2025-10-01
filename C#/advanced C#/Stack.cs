using System;
using System.Collections.Generic;
public class Stack<T>
{
    List<T> elements = new();
    public int Count => elements.Count;
    public bool IsEmpty => elements.Count == 0;
    public void Push(T item)
    {
        if (item == null)
            throw new ArgumentNullException("Item cannot be null.");
        elements.Add(item);
    }
    public T Pop()
    {
        if (IsEmpty)
            throw new InvalidOperationException("Stack is empty.");
        T item = elements[^1];
        elements.RemoveAt(elements.Count - 1);
        return item;
    }
    public T Peek()
    {
        if (IsEmpty)
            throw new InvalidOperationException("Stack is empty.");
        return elements[^1];
    }
    public void Clear() => elements.Clear();
    public void Print()
    {
        Console.WriteLine("Stack contents:");
        for (int i = elements.Count - 1; i >= 0; i--)
        {
            Console.WriteLine(elements[i]);
        }
    }
}