using System;
using System.Threading;

public class SimpleTimer
{
    private readonly int duration;
    private int remainingTime;
    private Timer? timer;

    public event Action<int>? Tick;       
    public event Action? Completed;       
    public int Duration => duration;         
    public int RemainingTime => remainingTime;    
    public double Progress => 
        (double)(duration - remainingTime) / duration * 100; 

    public SimpleTimer(int seconds)
    {
        if (seconds <= 0)
            throw new ArgumentException("Duration must be positive.");

        duration = seconds;
        remainingTime = seconds;
    }

    public void Start()
    {
        timer = new Timer(OnTick, null, 0, 1000);
    }

    private void OnTick(object? state)
    {
        remainingTime--;

        Tick?.Invoke(remainingTime);

        Console.WriteLine($"Progress: {Progress:F2}%");

        if (remainingTime % 60 == 0 && remainingTime > 0)
            Console.WriteLine($"Remaining time: {remainingTime / 60} minutes");
        Console.WriteLine($"tick: {remainingTime} seconds left");
        if (remainingTime <= 0)
        {
            timer?.Dispose();
            Completed?.Invoke();
        }
    }
}
