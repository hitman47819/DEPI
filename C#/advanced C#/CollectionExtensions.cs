using System;
using System.Collections.Generic;
using System.Linq;

public static class CollectionExtensions
{
    public static List<TTarget> ConvertList<TSource, TTarget>(this List<TSource> source, Func<TSource, TTarget> converter)
    {
        if (source == null) throw new ArgumentNullException(nameof(source));
        if (converter == null) throw new ArgumentNullException(nameof(converter));

        List<TTarget> result = new();
        foreach (var item in source)
        {
            result.Add(converter(item));
        }
        return result;
    }

    public static double AverageNullable(this IEnumerable<int?> source)
    {
        if (source == null) throw new ArgumentNullException(nameof(source));

        var validNumbers = source.Where(n => n.HasValue).Select(n => n.Value).ToList();
        if (validNumbers.Count == 0)
            throw new InvalidOperationException("Sequence contains no non-null elements.");

        return validNumbers.Average();
    }
}
