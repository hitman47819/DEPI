using System;
using System.Threading;
using System.Threading.Tasks;

public static class SafeRunner
{
    public static void RunSafe(string section, Action action)
    {
        try
        {
            Thread.Sleep(500); // optional delay
            Console.WriteLine($"\n=== Running: {section} ===");
            action();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Error in {section}] {ex.Message}");
        }
    }

    public static async Task RunSafeAsync(string section, Func<Task> action)
        {
            try
            {
                Console.WriteLine($"\n=== Running: {section} ===");
                await action();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Error in {section}] {ex.Message}");
            }
        }

}
