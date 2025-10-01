using System;
using System.Threading.Tasks;

public static class AsyncEmailSender
{
    public static async Task SendEmailsAsync(string[] recipients, string subject, string body)
    {
        foreach (var email in recipients)
        {
            // Fake send delay
            await Task.Delay(500);
            Console.WriteLine($"Email sent to {email}: Subject='{subject}', Body='{body}' (simulated)");
        }
    }
}
