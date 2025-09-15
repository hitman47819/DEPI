using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Examination_System
{
    internal class Student
    {
        private static int idCounter = 0;
        private static List<Student> allStudents = new List<Student>(); 

        private int id;
        private string name;
        private string email;
        private List<Course> enrolledCourses;
        private Dictionary<Exam, ExamResult> examResults;

        private Student(string name, string email)
        {
            if (!IsNameValid(name))
                throw new ArgumentException("Name must contain only letters and spaces.");

            if (!IsEmailValid(email))
                throw new ArgumentException("Email must contain '@'.");

            this.id = ++idCounter;
            this.name = name;
            this.email = email;
            this.enrolledCourses = new List<Course>();
            this.examResults = new Dictionary<Exam, ExamResult>();
        }

        private bool IsNameValid(string name) => Regex.IsMatch(name, @"^[A-Za-z\s]+$");

        private bool IsEmailValid(string email) => !string.IsNullOrWhiteSpace(email) && email.Contains("@");

        public static Student CreateStudent(string name, string email)
        {
            if (allStudents.Any(s => s.Email.Equals(email, StringComparison.OrdinalIgnoreCase)))
            {
                throw new InvalidOperationException("A student with this email already exists.");
            }

            Student newStudent = new Student(name, email);
            allStudents.Add(newStudent);
            return newStudent;
        }

        public static List<Student> GetAllStudents() => new List<Student>(allStudents);

   
        public string Name
        {
            get => name;
            set => name = value; 
        }

        public int Id
        {
            get => id;
            set => id = value; 
        }

        public string Email
        {
            get => email;
            set => email = value; 
        }


        public List<Course> GetEnrolledCourses() => new List<Course>(enrolledCourses);

        public void EnrollInCourse(Course course)
        {
            if (course == null) throw new ArgumentNullException(nameof(course));

            if (!enrolledCourses.Contains(course))
            {
                enrolledCourses.Add(course);
                course.EnrollStudent(this); 
            }
        }

        public bool UnenrollFromCourse(Course course)
        {
            if (course == null) throw new ArgumentNullException(nameof(course));
            return enrolledCourses.Remove(course);
        }

        public bool HasTakenExam(Exam exam)
        {
            if (exam == null) throw new ArgumentNullException(nameof(exam));
            return examResults.ContainsKey(exam);
        }

        public void AddExamResult(ExamResult result)
        {
            if (result == null) throw new ArgumentNullException(nameof(result));
            if (result.Exam == null) throw new ArgumentException("Result must reference an Exam.");

            examResults[result.Exam] = result;
        }

        public void TakeExam(Exam exam)
        {
            if (exam == null) throw new ArgumentNullException(nameof(exam));

            if (HasTakenExam(exam))
                throw new InvalidOperationException("Exam already taken.");

            if (!enrolledCourses.Contains(exam.Course))
                throw new InvalidOperationException("Student must be enrolled in the course to take the exam.");

            if (!exam.IsRunning())
                throw new InvalidOperationException("Exam is not currently available.");

            Console.WriteLine($"\n{this.Name} is taking exam: {exam.Title}");

            var answers = new Dictionary<Question, string>();

            foreach (var question in exam.Questions)
            {
                Console.WriteLine($"\nQ: {question.Text} (Marks: {question.Marks})");

                if (question is MCQQuestion mcq)
                {
                    for (int i = 0; i < mcq.Options.Count; i++)
                    {
                        Console.WriteLine($"{i + 1}. {mcq.Options[i]}");
                    }
                }

                Console.Write("Answer: ");
                string rawAnswer = Console.ReadLine()?.Trim() ?? "";

                if (question is MCQQuestion)
                {
                    if (int.TryParse(rawAnswer, out int selected1Based))
                    {
                        int storedIndex = selected1Based - 1;
                        answers[question] = storedIndex.ToString();
                    }
                    else
                    {
                        answers[question] = rawAnswer;
                    }
                }
                else
                {
                    answers[question] = rawAnswer;
                }
            }

            var result = new ExamResult(this, exam, answers);
            result.CalculateAutoScore();

            AddExamResult(result);

            Console.WriteLine($"Exam submitted. Current Score: {result.Score}/{exam.Course.MaxDegree}");
        }

        public ExamResult GetResult(Exam exam)
        {
            return examResults.ContainsKey(exam) ? examResults[exam] : null;
        }

        public void ShowAllResults()
        {
            Console.WriteLine($"\nResults for {Name}:");
            foreach (var kvp in examResults)
            {
                var exam = kvp.Key;
                var result = kvp.Value;
                string status = result.Score >= (exam.Course.MaxDegree / 2) ? "Pass" : "Fail";
                Console.WriteLine($"Exam: {exam.Title}, Score: {result.Score}/{exam.Course.MaxDegree}, Status: {status}");
            }
        }
    }
}
