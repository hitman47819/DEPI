using System;
using System.Collections.Generic;
using System.Linq;

namespace Examination_System
{
    internal class Exam
    {
        private readonly List<Question> questions = new List<Question>();
        private bool isLocked = false;

        public string Title { get; private set; }
        public Course Course { get; private set; }
        public Instructor Instructor { get; private set; }
        public DateTime StartTime { get; private set; }
        public TimeSpan Duration { get; private set; }
        public bool IsLocked => isLocked;

        public IReadOnlyList<Question> Questions => questions.AsReadOnly();

        public int TotalMarks => questions.Sum(q => q.Marks);

        public Exam(string title, Course course, Instructor instructor, DateTime startTime, DateTime endTime)
        {
            if (endTime <= startTime)
                throw new ArgumentException("End time must be after start time.");

            Title = title ?? throw new ArgumentNullException(nameof(title));
            Course = course ?? throw new ArgumentNullException(nameof(course));
            Instructor = instructor ?? throw new ArgumentNullException(nameof(instructor));

            StartTime = startTime;
            Duration = endTime - startTime;
        }

        private bool HasStarted => DateTime.Now >= StartTime;
        public List<Question> GetQuestions()
        {
            return new List<Question>(questions);
        }
        public Question GetQuestionByIndex(int index)
        {
            if (index < 0 || index >= questions.Count)
                throw new ArgumentOutOfRangeException(nameof(index), "Invalid question index.");

            return questions[index];
        }
        public void ClearQuestions()
        {
            EnsureEditable();
            questions.Clear();
        }

        private void EnsureEditable()
        {
            return;
            if (HasStarted || isLocked)
                throw new InvalidOperationException("Exam cannot be modified after it has started or if it is locked.");
        }
        public void UnassignInstructor()
        {
            EnsureEditable();

            Instructor = null;
        }
        public void ChangeCourse(Course newCourse)
        {
            EnsureEditable();
            Course = newCourse ?? throw new ArgumentNullException(nameof(newCourse));
        }

        public void LockExam()
        {
            isLocked = true;
        }

        public void AddQuestion(Question question)
        {
            EnsureEditable();

            if (question == null)
                throw new ArgumentNullException(nameof(question));

            if (questions.Contains(question))
                throw new InvalidOperationException("This question is already added.");

            if (TotalMarks + question.Marks > Course.MaxDegree)
                throw new InvalidOperationException("Cannot exceed course maximum degree.");

            questions.Add(question);
        }

        public void RemoveQuestion(Question question)
        {
            EnsureEditable();

            if (question == null || !questions.Contains(question))
                throw new InvalidOperationException("Question does not exist in this exam.");

            questions.Remove(question);
        }

        public Exam DuplicateExam(Course newCourse, Instructor newInstructor, DateTime newStart, DateTime newEnd)
        {
            var duplicate = new Exam(this.Title + " (Copy)", newCourse, newInstructor, newStart, newEnd);

            foreach (var q in this.questions)
            {
                duplicate.AddQuestion(q.Clone());
            }

            return duplicate;
        }
        public void AssignInstructor(Instructor instructor)
        {
            EnsureEditable();

            Instructor = instructor ?? throw new ArgumentNullException(nameof(instructor));
        }

        public void EditTitle(string newTitle)
        {
            EnsureEditable();
            Title = newTitle ?? throw new ArgumentNullException(nameof(newTitle));
        }

        public bool IsRunning()
        {
            return true;
            return DateTime.Now >= StartTime && DateTime.Now <= StartTime.Add(Duration);
        }

        public bool IsFinished()
        {
            return DateTime.Now > StartTime.Add(Duration);
        }
        public void Reschedule(DateTime newStart, DateTime newEnd)
        {
            EnsureEditable();

            if (newEnd <= newStart)
                throw new ArgumentException("End time must be after start time.");

            StartTime = newStart;
            Duration = newEnd - newStart;
        }

        public void DisplayExamInfo()
        {
            Console.WriteLine($"Exam: {Title}");
            Console.WriteLine($"Course: {Course.Title}");
            Console.WriteLine($"Instructor: {Instructor.Name}");
            Console.WriteLine($"Start Time: {StartTime}");
            Console.WriteLine($"Duration: {Duration}");
            Console.WriteLine($"Total Marks: {TotalMarks} / {Course.MaxDegree}");
            Console.WriteLine($"Questions: {questions.Count}");
        }
    }
}
