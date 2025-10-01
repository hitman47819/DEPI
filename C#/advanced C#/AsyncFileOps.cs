using System;
using System.IO;
using System.Threading.Tasks;

public static class AsyncFileOps
{
    public static async Task ReadFileAsync(string path)
    {
        if (!File.Exists(path))
        {
            Console.WriteLine($"File {path} not found. Creating a test file.");
            await File.WriteAllTextAsync(path, "This is a test file.");
        }

        string content = await File.ReadAllTextAsync(path);
        Console.WriteLine($"Read from {path}: {content}");
    }

    public static async Task WriteFileAsync(string path, string content)
    {
        await File.WriteAllTextAsync(path, content);
        Console.WriteLine($"Written to {path}: {content}");
    }
}
