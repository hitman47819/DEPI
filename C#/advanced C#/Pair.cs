using System;
using System.Collections.Generic;
public class Pair<T, U>
{
    public T First { get; set; }
    public U Second { get; set; }
    public override string ToString()
    {
        return $"({First}, {Second})";
    }

    public Pair(T first, U second)
    {
        First = first;
        Second = second;
    }
}