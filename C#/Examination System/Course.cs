using System;
using System.Collections.Generic;
using System.Linq;

namespace Examination_System
{
    internal class Course
    {
        public string Title { get; private set; }
        public string Description { get; private set; }
        public int MaxDegree { get; private set; }

        private List<Student> enrolledStudents = new List<Student>();
        private List<Instructor> instructors = new List<Instructor>();
        private List<Exam> exams = new List<Exam>();

        public IReadOnlyList<Student> EnrolledStudents => enrolledStudents.AsReadOnly();
        public IReadOnlyList<Instructor> Instructors => instructors.AsReadOnly();
        public IReadOnlyList<Exam> Exams => exams.AsReadOnly();

        public Course(string title, string description, int maxDegree)
        {
            Title = title;
            Description = description;
            MaxDegree = maxDegree;
        }

        public void EnrollStudent(Student student)
        {
            if (student == null) throw new ArgumentNullException(nameof(student));
            if (!enrolledStudents.Contains(student))
                enrolledStudents.Add(student);
        }
        public bool RemoveStudent(Student student)
        {
            if (student == null)
                throw new ArgumentNullException(nameof(student));

            bool removed = enrolledStudents.Remove(student);

            if (removed)
            {
                student.UnenrollFromCourse(this);
            }

            return removed;
        }

        public void AssignInstructor(Instructor instructor)
        {
            if (instructor == null) throw new ArgumentNullException(nameof(instructor));
            if (!instructors.Contains(instructor))
                instructors.Add(instructor);
        }

        public void UnassignInstructor(Instructor instructor)
        {
            if (instructor == null) throw new ArgumentNullException(nameof(instructor));
            instructors.Remove(instructor);
        }

        public void AddExam(Exam exam)
        {
            if (exam == null) throw new ArgumentNullException(nameof(exam));
            if (exam.Course != this)
                throw new InvalidOperationException("This exam does not belong to this course.");

            exams.Add(exam);
        }

        public bool RemoveExam(Exam exam)
        {
            if (exam == null) return false;
            return exams.Remove(exam);
        }

        public void GenerateReport()
        {
            Console.WriteLine($"\nReport for Course: {Title}");

            foreach (var exam in exams)
            {
                Console.WriteLine($"  Exam: {exam.Title}");

                foreach (var student in enrolledStudents)
                {
                    var result = student.GetResult(exam);
                    if (result != null)
                    {
                        string status = result.Score >= (MaxDegree / 2) ? "Pass" : "Fail";
                        Console.WriteLine($"    Student: {student.Name}, Score: {result.Score}, Status: {status}");
                    }
                }
            }
        }

        public void CompareStudents(Exam exam)
        {
            if (exam == null) throw new ArgumentNullException(nameof(exam));

            Console.WriteLine($"\nComparison for Exam: {exam.Title}");

            var results = new List<(Student student, ExamResult result)>();

            foreach (var student in enrolledStudents)
            {
                var result = student.GetResult(exam);
                if (result != null)
                {
                    results.Add((student, result));
                }
            }

            foreach (var item in results.OrderByDescending(r => r.result.Score))
            {
                Console.WriteLine($"Student: {item.student.Name}, Score: {item.result.Score}");
            }
        }

        public override string ToString()
        {
            return $"Course: {Title} (Max Degree: {MaxDegree})";
        }
    }
}
