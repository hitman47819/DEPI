USE ExaminationSystem;
GO

-- Sample data for UserAccount
INSERT INTO dbo.UserAccount (UserName, PasswordHash, Role) VALUES
("admin_user", "hashed_password_admin", "Admin"),
("manager_user", "hashed_password_manager", "Manager"),
("instructor_user", "hashed_password_instructor", "Instructor"),
("student_user", "hashed_password_student", "Student");
GO

-- Sample data for Branch
INSERT INTO dbo.Branch (BranchName) VALUES
("Computer Science"),
("Information Systems");
GO

-- Sample data for Track
INSERT INTO dbo.Track (TrackName, BranchID) VALUES
("Software Engineering", 1),
("Data Science", 1),
("Cyber Security", 2);
GO

-- Sample data for Intake
INSERT INTO dbo.Intake (IntakeName, StartDate, EndDate) VALUES
("Fall 2024", "2024-09-01", "2025-01-31"),
("Spring 2025", "2025-02-01", "2025-06-30");
GO

-- Sample data for Instructor
INSERT INTO dbo.Instructor (UserID, FullName, Email) VALUES
(3, "Dr. Ahmed Ali", "ahmed.ali@example.com");
GO

-- Sample data for Student
INSERT INTO dbo.Student (UserID, FullName, Email, BranchID, TrackID, IntakeID) VALUES
(4, "Sara Mohamed", "sara.mohamed@example.com", 1, 1, 1);
GO

-- Sample data for Course
INSERT INTO dbo.Course (CourseName, Description, MaxDegree, MinDegree, InstructorID, BranchID, TrackID, IntakeID) VALUES
("Database Systems", "Introduction to database concepts", 100, 50, 1, 1, 1, 1),
("Programming I", "Fundamentals of programming", 100, 50, 1, 1, 1, 1);
GO

-- Sample data for Question
INSERT INTO dbo.Question (CourseID, QuestionText, QuestionType, CorrectAnswerText) VALUES
(1, "What is a primary key?", "Text", "A unique identifier for a record."),
(1, "Which of the following is a DDL command?", "MultipleChoice", "CREATE"),
(1, "True or False: SQL is case-sensitive.", "TrueFalse", "False");
GO

-- Sample data for MultipleChoiceOption
INSERT INTO dbo.MultipleChoiceOption (QuestionID, OptionText, IsCorrect) VALUES
(2, "SELECT", 0),
(2, "INSERT", 0),
(2, "CREATE", 1),
(2, "UPDATE", 0);
GO

-- Sample data for Exam
INSERT INTO dbo.Exam (CourseID, InstructorID, ExamType, IntakeID, BranchID, TrackID, StartTime, EndTime, TotalTimeMinutes, AllowanceOptions) VALUES
(1, 1, "Midterm", 1, 1, 1, "2025-01-15 10:00:00", "2025-01-15 11:00:00", 60, NULL);
GO

-- Sample data for ExamQuestion
INSERT INTO dbo.ExamQuestion (ExamID, QuestionID, DegreePerQuestion) VALUES
(1, 1, 40),
(1, 2, 30),
(1, 3, 30);
GO

-- Sample data for ExamStudent
INSERT INTO dbo.ExamStudent (ExamID, StudentID, ExamDate, StartTime, EndTime) VALUES
(1, 1, "2025-01-15", "10:00:00", "11:00:00");
GO

-- Sample data for Answer
INSERT INTO dbo.Answer (ExamID, QuestionID, StudentID, AnswerText, IsCorrect, ScoreAwarded) VALUES
(1, 1, 1, "A unique identifier for a record.", 1, 40),
(1, 2, 1, "CREATE", 1, 30),
(1, 3, 1, "False", 1, 30);
GO

