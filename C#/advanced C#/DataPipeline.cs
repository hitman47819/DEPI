using System;
using System.Collections.Generic;
using System.Linq;

public class DataPipeline<T>
{
    private readonly List<Func<IEnumerable<T>, IEnumerable<T>>> steps = new();

    public void AddStep(Func<IEnumerable<T>, IEnumerable<T>> step)
    {
        if (step == null) throw new ArgumentNullException(nameof(step));
        steps.Add(step);
    }

    public IEnumerable<T> Execute(IEnumerable<T> data)
    {
        if (data == null) throw new ArgumentNullException(nameof(data));

        IEnumerable<T> result = data;
        foreach (var step in steps)
        {
            result = step(result) ?? Enumerable.Empty<T>();
        }
        return result;
    }
}