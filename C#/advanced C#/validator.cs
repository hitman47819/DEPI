using System;
using System.Collections.Generic;

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}

public class Validator<T>
{
    private readonly List<Func<T, bool>> rules = new();
    private readonly List<string> messages = new();

    public void AddRule(Func<T, bool> rule, string errorMessage)
    {
        if (rule == null) throw new ArgumentNullException(nameof(rule));
        rules.Add(rule);
        messages.Add(errorMessage);
    }

    public void Validate(T item)
    {
        for (int i = 0; i < rules.Count; i++)
        {
            if (!rules[i](item))
                throw new ValidationException(messages[i]);
        }
    }
}
