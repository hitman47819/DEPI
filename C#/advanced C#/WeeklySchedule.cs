using System;
using System.Collections.Generic;
public class WeeklySchedule
{
    private readonly Dictionary<DayOfWeek, List<string>> schedule = new();

    public List<string> this[DayOfWeek day]
    {
        get => schedule[day];
    }

    public string this[DayOfWeek day, int index]
    {
        get
        {
            if (index < 0 || index >= schedule[day].Count)
                throw new IndexOutOfRangeException("Task index is out of range.");
            return schedule[day][index];
        }
        set
        {
            if (index < 0 || index >= schedule[day].Count)
                throw new IndexOutOfRangeException("Task index is out of range.");
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Task cannot be null or empty.");
            schedule[day][index] = value;
        }
    }

    public WeeklySchedule()
    {
        foreach (DayOfWeek day in Enum.GetValues(typeof(DayOfWeek)))
        {
            schedule[day] = new List<string>();
        }
    }

    public void AddTask(DayOfWeek day, string task)
    {
        if (string.IsNullOrWhiteSpace(task))
            throw new ArgumentException("Task cannot be null or empty.");
        schedule[day].Add(task);
    }

    public void RemoveTask(DayOfWeek day, string task)
    {
        if (string.IsNullOrWhiteSpace(task))
            throw new ArgumentException("Task cannot be null or empty.");
        if (!schedule[day].Remove(task))
            throw new KeyNotFoundException($"Task '{task}' not found on {day}.");
    }

    public void UpdateTask(DayOfWeek day, string oldTask, string newTask)
    {
        if (string.IsNullOrWhiteSpace(oldTask) || string.IsNullOrWhiteSpace(newTask))
            throw new ArgumentException("Tasks cannot be null or empty.");
        int index = schedule[day].IndexOf(oldTask);
        if (index == -1)
            throw new KeyNotFoundException($"Task '{oldTask}' not found on {day}.");
        schedule[day][index] = newTask;
    }

    public IReadOnlyList<string> GetTasks(DayOfWeek day) => schedule[day].AsReadOnly();

    public void ClearTasks(DayOfWeek day) => schedule[day].Clear();

    public bool HasTask(DayOfWeek day, string task) => schedule[day].Contains(task);
}
