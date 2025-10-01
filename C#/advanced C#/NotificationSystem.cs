using System;

public class NotificationSystem
{
    public delegate void NotifyHandler(string message);

    private event NotifyHandler? OnNotify;

    public void RegisterChannel(NotifyHandler handler)
    {
        if (handler == null) throw new ArgumentNullException(nameof(handler));
        OnNotify += handler;
    }

    public void UnregisterChannel(NotifyHandler handler)
    {
        if (handler == null) throw new ArgumentNullException(nameof(handler));
        OnNotify -= handler;
    }

    public void Send(string message)
    {
        if (OnNotify == null) return;

        foreach (NotifyHandler handler in OnNotify.GetInvocationList())
        {
            try
            {
                handler(message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Notification Error] {ex.Message}");
            }
        }
    }

    public int SendWithStatus(string message)
    {
        int successCount = 0;
        if (OnNotify == null) return successCount;

        foreach (NotifyHandler handler in OnNotify.GetInvocationList())
        {
            try
            {
                handler(message);
                successCount++;
            }
            catch { }
        }
        return successCount;
    }
}