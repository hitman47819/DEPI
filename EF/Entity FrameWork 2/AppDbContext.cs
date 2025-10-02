using Entity_FrameWork_2.Models;
using Microsoft.EntityFrameworkCore;

namespace EFW2
{
    public class AppDbContext : Microsoft.EntityFrameworkCore.DbContext
    {
        public DbSet<Course> Courses { get; set; }
        public DbSet<Student> Students { get; set; }
        public DbSet<Instructor> Instructors { get; set; }
        public DbSet<Exam> Exams { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<MultipleChoiceQuestion> MultipleChoiceQuestions { get; set; }
        public DbSet<TrueFalseQuestion> TrueFalseQuestions { get; set; }
        public DbSet<EssayQuestion> EssayQuestions { get; set; }
        public DbSet<StudentCourse> StudentCourses { get; set; }
        public DbSet<InstructorCourse> InstructorCourses { get; set; }
        public DbSet<ExamAttempt> ExamAttempts { get; set; }
        public DbSet<StudentAnswer> StudentAnswers { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer(@"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ExamSystemDb;Integrated Security=True;");
        }
        [Obsolete]
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<StudentCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });

            modelBuilder.Entity<InstructorCourse>()
                .HasKey(ic => new { ic.InstructorId, ic.CourseId });

            modelBuilder.Entity<Student>()
                .HasIndex(s => s.Email)
                .IsUnique();

            modelBuilder.Entity<Student>()
                .HasIndex(s => s.StudentNumber)
                .IsUnique();

            modelBuilder.Entity<Instructor>()
                .HasIndex(i => i.Email)
                .IsUnique();

           
            modelBuilder.Entity<Course>()
                .HasMany(c => c.Exams)
                .WithOne(e => e.Course)
                .HasForeignKey(e => e.CourseId)
                .OnDelete(DeleteBehavior.Restrict);

             modelBuilder.Entity<Exam>()
                .HasMany(e => e.Questions)
                .WithOne(q => q.Exam)
                .HasForeignKey(q => q.ExamId)
                .OnDelete(DeleteBehavior.Restrict);

             modelBuilder.Entity<ExamAttempt>()
                .HasMany(ea => ea.StudentAnswers)
                .WithOne(sa => sa.ExamAttempt)
                .HasForeignKey(sa => sa.ExamAttemptId)
                .OnDelete(DeleteBehavior.Restrict);

             modelBuilder.Entity<Student>()
                .HasMany(s => s.ExamAttempts)
                .WithOne(ea => ea.Student)
                .HasForeignKey(ea => ea.StudentId)
                .OnDelete(DeleteBehavior.Restrict);

             modelBuilder.Entity<Exam>()
                .HasCheckConstraint("CK_Exam_EndDate", "[EndDate] > [StartDate]");

            modelBuilder.Entity<Question>()
                .HasCheckConstraint("CK_Question_Marks", "[Marks] > 0");

            modelBuilder.Entity<Course>()
                .HasCheckConstraint("CK_Course_MaximumDegree", "[MaximumDegree] > 0");

             modelBuilder.Entity<Student>()
                .HasIndex(s => s.Email);

            modelBuilder.Entity<Exam>()
                .HasIndex(e => e.StartDate);

            modelBuilder.Entity<ExamAttempt>()
                .HasIndex(ea => ea.StartTime);

             modelBuilder.Entity<Question>()
                .HasDiscriminator(q => q.QuestionType)
                .HasValue<MultipleChoiceQuestion>(QuestionType.MultipleChoice)
                .HasValue<TrueFalseQuestion>(QuestionType.TrueFalse)
                .HasValue<EssayQuestion>(QuestionType.Essay);
            SeedInitialData(modelBuilder);

        }
        private void SeedInitialData(ModelBuilder modelBuilder)
        {
            // Static base date
            var baseDate = new DateTime(2025, 10, 2);

            modelBuilder.Entity<Course>().HasData(
                new Course { Id = 1, Title = "Mathematics", Description = "Basic Math", MaximumDegree = 100, CreatedDate = baseDate, IsActive = true },
                new Course { Id = 2, Title = "Physics", Description = "Basic Physics", MaximumDegree = 100, CreatedDate = baseDate, IsActive = true },
                new Course { Id = 3, Title = "Computer Science", Description = "Intro to CS", MaximumDegree = 100, CreatedDate = baseDate, IsActive = true }
            );

            modelBuilder.Entity<Student>().HasData(
                new Student { Id = 1, Name = "Alice", Email = "alice@example.com", StudentNumber = "S001", EnrollmentDate = baseDate, IsActive = true },
                new Student { Id = 2, Name = "Bob", Email = "bob@example.com", StudentNumber = "S002", EnrollmentDate = baseDate, IsActive = true },
                new Student { Id = 3, Name = "Charlie", Email = "charlie@example.com", StudentNumber = "S003", EnrollmentDate = baseDate, IsActive = true },
                new Student { Id = 4, Name = "Diana", Email = "diana@example.com", StudentNumber = "S004", EnrollmentDate = baseDate, IsActive = true },
                new Student { Id = 5, Name = "Eve", Email = "eve@example.com", StudentNumber = "S005", EnrollmentDate = baseDate, IsActive = true }
            );

            modelBuilder.Entity<Instructor>().HasData(
                new Instructor { Id = 1, Name = "Dr. Smith", Email = "smith@example.com", Specialization = "Mathematics", HireDate = baseDate, IsActive = true },
                new Instructor { Id = 2, Name = "Dr. Johnson", Email = "johnson@example.com", Specialization = "Physics", HireDate = baseDate, IsActive = true }
            );

            modelBuilder.Entity<Exam>().HasData(
                new Exam
                {
                    Id = 1,
                    Title = "Math Exam",
                    Description = "Algebra & Geometry",
                    TotalMarks = 100,
                    Duration = new TimeSpan(1, 30, 0),
                    StartDate = baseDate.AddDays(7),
                    EndDate = baseDate.AddDays(7).AddHours(2),
                    CourseId = 1,
                    InstructorId = 1,
                    IsActive = true
                },
                new Exam
                {
                    Id = 2,
                    Title = "Physics Exam",
                    Description = "Mechanics",
                    TotalMarks = 100,
                    Duration = new TimeSpan(1, 30, 0),
                    StartDate = baseDate.AddDays(10),
                    EndDate = baseDate.AddDays(10).AddHours(2),
                    CourseId = 2,
                    InstructorId = 2,
                    IsActive = true
                }
            );

            modelBuilder.Entity<MultipleChoiceQuestion>().HasData(
                new MultipleChoiceQuestion
                {
                    Id = 1,
                    ExamId = 1,
                    QuestionText = "2+2=?",
                    Marks = 5,
                    QuestionType = QuestionType.MultipleChoice,
                    CreatedDate = baseDate,
                    OptionA = "3",
                    OptionB = "4",
                    OptionC = "5",
                    OptionD = "6",
                    CorrectOption = 'B'
                }
            );

            modelBuilder.Entity<TrueFalseQuestion>().HasData(
                new TrueFalseQuestion
                {
                    Id = 2,
                    ExamId = 2,
                    QuestionText = "Newton's 2nd law applies to F=ma?",
                    Marks = 5,
                    QuestionType = QuestionType.TrueFalse,
                    CreatedDate = baseDate,
                    CorrectAnswer = true
                }
            );

            modelBuilder.Entity<EssayQuestion>().HasData(
                new EssayQuestion
                {
                    Id = 3,
                    ExamId = 1,
                    QuestionText = "Explain Pythagoras theorem.",
                    Marks = 10,
                    QuestionType = QuestionType.Essay,
                    CreatedDate = baseDate,
                    MaxWordCount = 200,
                    GradingCriteria = "Clarity, correctness, examples"
                }
            );
        }




    }
}
