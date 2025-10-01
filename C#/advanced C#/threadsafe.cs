using System;
using System.Threading;

public class ThreadSafeCounter
{
    private int count = 0;

    public int Count => count;

    public void Increment()
    {
        Interlocked.Increment(ref count);
    }

    public void Decrement()
    {
        Interlocked.Decrement(ref count);
    }

    public void Reset()
    {
        Interlocked.Exchange(ref count, 0);
    }
}

