using System;
using System.Collections.Generic;
using System.Linq;

namespace Examination_System
{
    internal class ExamResult
    {
        public Student Student { get; }
        public Exam Exam { get; }
        private readonly Dictionary<Question, string> answers = new();
        private readonly Dictionary<Question, int> grades = new();

        public IReadOnlyDictionary<Question, string> Answers => answers;
        public IReadOnlyDictionary<Question, int> Grades => grades;

        public int TotalGrade => grades.Values.Sum();

        public ExamResult(Student student, Exam exam)
        {
            Student = student ?? throw new ArgumentNullException(nameof(student));
            Exam = exam ?? throw new ArgumentNullException(nameof(exam));
        }

        public ExamResult(Student student, Exam exam, Dictionary<Question, string> answers)
            : this(student, exam)
        {
            foreach (var kvp in answers)
            {
                AddAnswer(kvp.Key, kvp.Value);
            }
        }

        public void AddAnswer(Question question, string answer)
        {
            if (question == null)
                throw new ArgumentNullException(nameof(question));

            if (string.IsNullOrWhiteSpace(answer))
                throw new ArgumentException("Answer cannot be empty.");

            answers[question] = answer;

            if (question is EssayQuestion)
            {
                grades[question] = 0; 
            }
            else
            {
                grades[question] = question.Grade(answer);
            }
        }

        public void GradeEssay(EssayQuestion question, int grade)
        {
            if (question == null)
                throw new ArgumentNullException(nameof(question));

            if (!answers.ContainsKey(question))
                throw new InvalidOperationException("Student has not answered this essay question.");

            if (grade < 0 || grade > question.Marks)
                throw new ArgumentException("Invalid grade.");

            grades[question] = grade;

            question.SetGrade(grade);
        }


        public void CalculateAutoScore()
        {
            foreach (var kvp in answers)
            {
                var question = kvp.Key;
                var answer = kvp.Value;

                if (question is EssayQuestion)
                {
                    grades[question] = 0;
                }
                else
                {
                    grades[question] = question.Grade(answer);
                }
            }
        }

        public int Score => TotalGrade;
    }
}
