using System;

public static class DateTimeExtensions
{
    public static bool IsWeekend(this DateTime date) =>
        date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday;

    public static bool IsBusinessDay(this DateTime date) =>
        !date.IsWeekend();

    public static int Age(this DateTime birthDate)
    {
        var today = DateTime.Today;
        int age = today.Year - birthDate.Year;
        if (birthDate.Date > today.AddYears(-age)) age--;
        return age;
    }

    public static DateTime AddBusinessDays(this DateTime date, int businessDays)
    {
        if (businessDays < 0)
            throw new ArgumentException("businessDays must be non-negative");

        DateTime result = date;
        while (businessDays > 0)
        {
            result = result.AddDays(1);
            if (result.IsBusinessDay())
                businessDays--;
        }
        return result;
    }

    public static int BusinessDaysUntil(this DateTime start, DateTime end)
    {
        if (end < start)
            throw new ArgumentException("End date must be after start date");

        int businessDays = 0;
        DateTime current = start;
        while (current < end)
        {
            if (current.IsBusinessDay())
                businessDays++;
            current = current.AddDays(1);
        }
        return businessDays;
    }

    public static DateTime StartOfMonth(this DateTime date) =>
        new(date.Year, date.Month, 1);

    public static DateTime EndOfMonth(this DateTime date) =>
        new(date.Year, date.Month, DateTime.DaysInMonth(date.Year, date.Month));

    public static DateTime StartOfYear(this DateTime date) =>
        new(date.Year, 1, 1);

    public static DateTime EndOfYear(this DateTime date) =>
        new(date.Year, 12, 31);

    public static DateTime StartOfWeek(this DateTime date, DayOfWeek startOfWeek = DayOfWeek.Friday)
    {
        int diff = (7 + (date.DayOfWeek - startOfWeek)) % 7;
        return date.AddDays(-diff).Date;
    }

    public static DateTime EndOfWeek(this DateTime date, DayOfWeek startOfWeek = DayOfWeek.Friday) =>
        date.StartOfWeek(startOfWeek).AddDays(6);
}

 
