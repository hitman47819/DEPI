 using System;
using System.Threading;
using System.Threading.Tasks;

public class AsyncWorker
{
    private CancellationTokenSource? cts;

    public void Start()
    {
        cts = new CancellationTokenSource();
        Task.Run(async () =>
        {
            int counter = 0;
            while (!cts.Token.IsCancellationRequested)
            {
                Console.WriteLine($"Async Worker running: iteration {++counter}");
                await Task.Delay(1000);
            }
        }, cts.Token);
    }

    public void Stop()
    {
        if (cts != null)
        {
            cts.Cancel();
            Console.WriteLine("Async Worker stopped.");
        }
    }
}
