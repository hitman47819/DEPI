using System;
using System.Threading.Tasks;

public static class AsyncDownloader
{
    public static async Task DownloadFilesAsync(string[] urls)
    {
        foreach (var url in urls)
        {
            // Fake download delay
            await Task.Delay(1000);
            Console.WriteLine($"Downloaded content from {url} (simulated)");
        }
    }
}
