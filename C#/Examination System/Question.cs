using System;
using System.Collections.Generic;

namespace Examination_System
{
    internal abstract class Question
    {
        public string Text {get; set;}   
        public int Marks { get;set; }

        protected Question(string text, int marks)
        {
            if (string.IsNullOrWhiteSpace(text))
                throw new ArgumentException("Question text cannot be empty.");

            if (marks < 0)
                throw new ArgumentException("Marks must be positive.");

            Text = text;
            Marks = marks;
        }

        public abstract Question Clone();
        public abstract int Grade(string studentAnswer);
    }

    internal class MCQQuestion : Question
    {
        public List<string> Options { get; }
        public int CorrectOptionIndex { get; }

        public MCQQuestion(string text, int marks, List<string> options, int correctOptionIndex)
            : base(text, marks)
        {
            if (options == null || options.Count < 2)
                throw new ArgumentException("MCQ must have at least 2 options.");

            if (correctOptionIndex < 0 || correctOptionIndex >= options.Count)
                throw new ArgumentException("Invalid correct option index.");

            Options = new List<string>(options);
            CorrectOptionIndex = correctOptionIndex;
        }

        public override int Grade(string studentAnswer)
        {
            if (int.TryParse(studentAnswer, out int index) &&
                index >= 0 && index < Options.Count &&  index == CorrectOptionIndex)
                return Marks;

            return 0;
        }

        public override Question Clone()
        {
            return new MCQQuestion(this.Text, this.Marks, new List<string>(this.Options), this.CorrectOptionIndex);
        }
    }

    internal class TrueFalseQuestion : Question
    {
        public bool CorrectAnswer { get; }

        public TrueFalseQuestion(string text, int marks, bool correctAnswer)
            : base(text, marks)
        {
            CorrectAnswer = correctAnswer;
        }

        public override int Grade(string studentAnswer)
        {

            if (bool.TryParse(studentAnswer, out bool ans) && ans == CorrectAnswer)
                return Marks;

            return 0;
        }

        public override Question Clone()
        {
            return new TrueFalseQuestion(this.Text, this.Marks, this.CorrectAnswer);
        }
    }

    internal class EssayQuestion : Question
    {
        public string StudentAnswer { get; private set; }
        public int? ManualGrade { get; private set; }

        public EssayQuestion(string text, int marks)
            : base(text, marks) { }

        public void SubmitAnswer(string answer)
        {
            StudentAnswer = answer;
        }

        public void SetGrade(int grade)
        {
            if (grade < 0 || grade > Marks)
                throw new ArgumentException("Grade must be between 0 and the max marks for this question.");

            ManualGrade = grade;
        }

        public override int Grade(string studentAnswer)
        {
            return ManualGrade ?? 0;
        }

        public override Question Clone()
        {
            return new EssayQuestion(this.Text, this.Marks);
        }

        public void DisplayForInstructor()
        {
            Console.WriteLine($"Essay Question: {Text}");
            Console.WriteLine($"Student Answer: {StudentAnswer}");
            Console.WriteLine($"Max Marks: {Marks}");
            Console.WriteLine($"Current Grade: {(ManualGrade.HasValue ? ManualGrade.ToString() : "Not graded yet")}");
        }
    }
}
