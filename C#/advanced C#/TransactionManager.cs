using System;
using System.Collections.Generic;

public class TransactionManager
{
    private readonly List<Action> rollbackActions = new();

    public void Execute(Action action, Action rollback)
    {
        try
        {
            action();
            rollbackActions.Add(rollback);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}, rolling back...");
            rollback();
        }
    }

    public void RollbackAll()
    {
        foreach (var rollback in rollbackActions)
        {
            rollback();
        }
        rollbackActions.Clear();
    }
}
