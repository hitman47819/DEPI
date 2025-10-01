using System;
using System.Collections.Generic;
using System.Numerics;
public static class IntExtensions
{
    public static bool IsEven(this int number)
    {
        return number % 2 == 0;
    }
    public static bool IsOdd(this int number)
    {
        return number % 2 != 0;
    }
    public static bool isPrime(this int number)
    {
        if (number <= 1) return false;
        for (int i = 2; i <= Math.Sqrt(number); i++)
        {
            if (number % i == 0) return false;
        }
        return true;
    }
    public static string ToRoman(this int number)
    {
        if (number < 1 || number > 3999)
            throw new ArgumentOutOfRangeException("Value must be in the range 1-3999");

        var romanNumerals = new[]
        {
            new { Value = 1000, Symbol = "M" },
            new { Value = 900, Symbol = "CM" },
            new { Value = 500, Symbol = "D" },
            new { Value = 400, Symbol = "CD" },
            new { Value = 100, Symbol = "C" },
            new { Value = 90, Symbol = "XC" },
            new { Value = 50, Symbol = "L" },
            new { Value = 40, Symbol = "XL" },
            new { Value = 10, Symbol = "X" },
            new { Value = 9, Symbol = "IX" },
            new { Value = 5, Symbol = "V" },
            new { Value = 4, Symbol = "IV" },
            new { Value = 1, Symbol = "I" }
        };

        var result = string.Empty;
        foreach (var item in romanNumerals)
        {
            while (number >= item.Value)
            {
                result += item.Symbol;
                number -= item.Value;
            }
        }
        return result;
    }
 public static BigInteger Factorial(this int number)
{
    if (number < 0)
        throw new ArgumentException("Number must be non-negative.");
    BigInteger result = 1;
    for (int i = 2; i <= number; i++)
        result *= i;
    return result;
}

    
}