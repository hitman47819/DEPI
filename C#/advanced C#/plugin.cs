using System;
using System.Collections.Generic;

public class PluginSystem<T>
{
    public delegate void BusinessRuleHandler(T item);

    private readonly List<BusinessRuleHandler> rules = new();

    public void RegisterRule(BusinessRuleHandler rule)
    {
        if (rule == null) throw new ArgumentNullException(nameof(rule));
        rules.Add(rule);
    }

    public void UnregisterRule(BusinessRuleHandler rule)
    {
        rules.Remove(rule);
    }

    public void ExecuteRules(T item)
    {
        foreach (var rule in rules)
        {
            rule(item);
        }
    }
}
