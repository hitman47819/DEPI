using System.Text.RegularExpressions;

namespace Examination_System
{
    internal class Instructor
    {
        private static int idCounter = 0;
        private static List<Instructor> allInstructors = new List<Instructor>();

        private int id;
        private string name;
        private string specialization;
        private List<Course> courses;

        private Instructor(string name, string specialization)
        {
            if (!IsNameValid(name))
                throw new ArgumentException("Name must contain only letters and spaces.");

            if (!IsSpecializationValid(specialization))
                throw new ArgumentException("Specialization must contain only letters and spaces.");

            this.id = ++idCounter;
            this.name = name;
            this.specialization = specialization;
            this.courses = new List<Course>();
        }

        private bool IsNameValid(string name) => Regex.IsMatch(name, @"^[A-Za-z\s]+$");
        private bool IsSpecializationValid(string specializationName) => Regex.IsMatch(specializationName, @"^[A-Za-z\s]+$");

        public static Instructor CreateInstructor(string name, string specialization)
        {
            if (allInstructors.Any(i =>
                i.name.Equals(name, StringComparison.OrdinalIgnoreCase) &&
                i.specialization.Equals(specialization, StringComparison.OrdinalIgnoreCase)))
            {
                throw new InvalidOperationException("An instructor with this name and specialization already exists.");
            }

            Instructor newInstructor = new Instructor(name, specialization);
            allInstructors.Add(newInstructor);
            return newInstructor;
        }

        public static List<Instructor> GetAllInstructors() => new List<Instructor>(allInstructors);
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

        public string Specialization
        {
            get => specialization;
            set => specialization = value;
        }
   

        public void AssignCourse(Course course)
        {
            if (course == null)
                throw new ArgumentNullException(nameof(course));

            if (!courses.Contains(course))
            {
                courses.Add(course);
                course.AssignInstructor(this);
            }
        }

        public bool RemoveCourse(Course course)
        {
            if (courses.Remove(course))
            {
                course.UnassignInstructor(this);
                return true;
            }
            return false;
        }

        public IReadOnlyList<Course> GetCourses() => courses.AsReadOnly();

        public Exam CreateExam(Course course, string title, DateTime startTime, DateTime endTime)
        {
            if (!courses.Contains(course))
                throw new InvalidOperationException("Instructor must be assigned to this course to create an exam.");

            var exam = new Exam(title, course, this, startTime, endTime);
            course.AddExam(exam);
            return exam;
        }

        public void AddQuestionToExam(Exam exam, Question question)
        {
            if (!courses.Contains(exam.Course))
                throw new InvalidOperationException("Instructor must own the course of this exam.");

            exam.AddQuestion(question);
        }

        public override string ToString()
        {
            return $"Instructor: {Name} (Specialization: {Specialization}, ID: {Id})";
        }
    }
}
