 
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ExaminationSystem')
BEGIN
    DROP DATABASE ExaminationSystem;
END;

CREATE DATABASE ExaminationSystem;


 
USE ExaminationSystem;
GO

 IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ES_Admin')    DROP LOGIN ES_Admin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ES_Manager')  DROP LOGIN ES_Manager;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ES_Instructor')DROP LOGIN ES_Instructor;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ES_Student')  DROP LOGIN ES_Student;
GO

 CREATE LOGIN ES_Admin       WITH PASSWORD = 'P@ssw0rdAdmin!';
CREATE LOGIN ES_Manager     WITH PASSWORD = 'P@ssw0rdManager!';
CREATE LOGIN ES_Instructor  WITH PASSWORD = 'P@ssw0rdInstr!';
CREATE LOGIN ES_Student     WITH PASSWORD = 'P@ssw0rdStud!';
GO

CREATE USER ES_Admin       FOR LOGIN ES_Admin;
CREATE USER ES_Manager     FOR LOGIN ES_Manager;
CREATE USER ES_Instructor  FOR LOGIN ES_Instructor;
CREATE USER ES_Student     FOR LOGIN ES_Student;
GO

 EXEC sp_addrolemember 'db_owner',    'ES_Admin';
EXEC sp_addrolemember 'db_ddladmin', 'ES_Manager';
GO

 GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Branch TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Track  TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Intake TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Student TO ES_Manager;
GO

 GRANT EXECUTE ON sp_CreateExam               TO ES_Instructor;
GRANT EXECUTE ON sp_AddExamQuestion          TO ES_Instructor;
GRANT SELECT  ON vw_TextAnswersPendingReview TO ES_Instructor;
GRANT SELECT  ON vw_StudentExamResults       TO ES_Instructor;
GO

 GRANT SELECT  ON vw_StudentExamResults TO ES_Student;
GRANT INSERT, SELECT ON dbo.Answer         TO ES_Student;
GO
 
CREATE TABLE dbo.UserAccount (
    UserID         INT IDENTITY(1,1) PRIMARY KEY,
    Username       SYSNAME NOT NULL UNIQUE,
    PasswordHash   NVARCHAR(512) NOT NULL,
    Role           NVARCHAR(50) NOT NULL
        CONSTRAINT CHK_User_Role CHECK (Role IN ('Admin','Manager','Instructor','Student'))
);

CREATE TABLE dbo.Branch (
    BranchID     INT IDENTITY(1,1) PRIMARY KEY,
    BranchName   NVARCHAR(200) NOT NULL UNIQUE
) ON FG_Data;

CREATE TABLE dbo.Track (
    TrackID      INT IDENTITY(1,1) PRIMARY KEY,
    TrackName    NVARCHAR(200) NOT NULL,
    BranchID     INT NOT NULL REFERENCES dbo.Branch(BranchID),
    CONSTRAINT UQ_Track_Per_Branch UNIQUE(BranchID,TrackName)
) ON FG_Data;

CREATE TABLE dbo.Intake (
    IntakeID     INT IDENTITY(1,1) PRIMARY KEY,
    IntakeName   NVARCHAR(100) NOT NULL UNIQUE,
    StartDate    DATE NOT NULL,
    EndDate      DATE NOT NULL
) ON FG_Data;

CREATE TABLE dbo.Instructor (
    InstructorID INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT NOT NULL REFERENCES dbo.UserAccount(UserID),
    FullName     NVARCHAR(200) NOT NULL,
    Email        NVARCHAR(320) NOT NULL UNIQUE
) ON FG_Data;

CREATE TABLE dbo.Student (
    StudentID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT NOT NULL REFERENCES dbo.UserAccount(UserID),
    FullName     NVARCHAR(200) NOT NULL,
    Email        NVARCHAR(320) NOT NULL UNIQUE,
    BranchID     INT NOT NULL REFERENCES dbo.Branch(BranchID),
    TrackID      INT NOT NULL REFERENCES dbo.Track(TrackID),
    IntakeID     INT NOT NULL REFERENCES dbo.Intake(IntakeID)
) ON FG_Data;

CREATE TABLE dbo.Course (
    CourseID       INT IDENTITY(1,1) PRIMARY KEY,
    CourseName     NVARCHAR(200) NOT NULL,
    Description    NVARCHAR(MAX) NULL,
    MaxDegree      INT NOT NULL CHECK (MaxDegree > 0),
    MinDegree      INT NOT NULL CHECK (MinDegree >= 0 AND MinDegree < MaxDegree),
    InstructorID   INT NOT NULL REFERENCES dbo.Instructor(InstructorID),
    BranchID       INT NOT NULL REFERENCES dbo.Branch(BranchID),
    TrackID        INT NOT NULL REFERENCES dbo.Track(TrackID),
    IntakeID       INT NOT NULL REFERENCES dbo.Intake(IntakeID),
    CONSTRAINT UQ_Course_Per_Cohort UNIQUE(BranchID,TrackID,IntakeID,CourseName)
) ON FG_Data;

CREATE TABLE dbo.Question (
    QuestionID         INT IDENTITY(1,1) PRIMARY KEY,
    CourseID           INT NOT NULL REFERENCES dbo.Course(CourseID),
    QuestionText       NVARCHAR(MAX) NOT NULL,
    QuestionType       NVARCHAR(20) NOT NULL
        CONSTRAINT CHK_Question_Type CHECK (QuestionType IN ('MultipleChoice','TrueFalse','Text')),
    CorrectAnswerText  NVARCHAR(MAX) NULL,
    BestAcceptedAnswer NVARCHAR(MAX) NULL
) ON FG_Data;

CREATE TABLE dbo.MultipleChoiceOption (
    OptionID      INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID    INT NOT NULL REFERENCES dbo.Question(QuestionID),
    OptionText    NVARCHAR(500) NOT NULL,
    IsCorrect     BIT NOT NULL
) ON FG_Data;

CREATE TABLE dbo.Exam (
    ExamID           INT IDENTITY(1,1) PRIMARY KEY,
    CourseID         INT NOT NULL REFERENCES dbo.Course(CourseID),
    InstructorID     INT NOT NULL REFERENCES dbo.Instructor(InstructorID),
    ExamType         NVARCHAR(20) NOT NULL,
    IntakeID         INT NOT NULL REFERENCES dbo.Intake(IntakeID),
    BranchID         INT NOT NULL REFERENCES dbo.Branch(BranchID),
    TrackID          INT NOT NULL REFERENCES dbo.Track(TrackID),
    StartTime        DATETIME2 NOT NULL,
    EndTime          DATETIME2 NOT NULL,
    TotalTimeMinutes INT NOT NULL CHECK (TotalTimeMinutes > 0),
    AllowanceOptions NVARCHAR(500) NULL,
    TotalDegree      INT NOT NULL DEFAULT(0)
) ON FG_Data;

CREATE TABLE dbo.ExamQuestion (
    ExamID            INT NOT NULL REFERENCES dbo.Exam(ExamID),
    QuestionID        INT NOT NULL REFERENCES dbo.Question(QuestionID),
    DegreePerQuestion INT NOT NULL CHECK (DegreePerQuestion > 0),
    PRIMARY KEY (ExamID,QuestionID)
) ON FG_Data;

CREATE TABLE dbo.ExamStudent (
    ExamID    INT NOT NULL REFERENCES dbo.Exam(ExamID),
    StudentID INT NOT NULL REFERENCES dbo.Student(StudentID),
    ExamDate  DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime   TIME NOT NULL,
    PRIMARY KEY (ExamID,StudentID)
) ON FG_Data;

CREATE TABLE dbo.Answer (
    AnswerID      INT IDENTITY(1,1) PRIMARY KEY,
    ExamID        INT NOT NULL REFERENCES dbo.Exam(ExamID),
    QuestionID    INT NOT NULL REFERENCES dbo.Question(QuestionID),
    StudentID     INT NOT NULL REFERENCES dbo.Student(StudentID),
    AnswerText    NVARCHAR(MAX) NOT NULL,
    IsCorrect     BIT NULL,
    ScoreAwarded  INT NULL,
    ResultStored  BIT NOT NULL DEFAULT(0)
) ON FG_Data;

 CREATE INDEX IX_Answer_Exam_Student    ON dbo.Answer(ExamID,StudentID) ON FG_Data;
CREATE INDEX IX_Exam_Course            ON dbo.Exam(CourseID)           ON FG_Data;
CREATE INDEX IX_Question_By_CourseType ON dbo.Question(CourseID,QuestionType) ON FG_Data;
GO

 
CREATE TRIGGER trg_Exam_TotalDegree
ON dbo.Exam
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN dbo.Course c ON i.CourseID = c.CourseID
         WHERE i.TotalDegree > c.MaxDegree
    )
    BEGIN
        RAISERROR('TotalDegree exceeds MaxDegree.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

 CREATE TRIGGER trg_Answer_AutoScore
ON dbo.Answer
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE a
       SET a.IsCorrect = CASE 
                WHEN q.QuestionType IN ('MultipleChoice','TrueFalse')
                     AND a.AnswerText = q.CorrectAnswerText THEN 1
                WHEN q.QuestionType IN ('MultipleChoice','TrueFalse') THEN 0
                ELSE NULL
            END,
           a.ScoreAwarded = CASE
                WHEN q.QuestionType IN ('MultipleChoice','TrueFalse')
                     THEN eq.DegreePerQuestion * CASE WHEN a.AnswerText = q.CorrectAnswerText THEN 1 ELSE 0 END
                ELSE NULL
            END
      FROM dbo.Answer a
      JOIN inserted i      ON a.AnswerID = i.AnswerID
      JOIN dbo.Question q  ON a.QuestionID = q.QuestionID
      JOIN dbo.ExamQuestion eq
        ON a.ExamID = eq.ExamID
       AND a.QuestionID = eq.QuestionID
     WHERE q.QuestionType IN ('MultipleChoice','TrueFalse');
END;
GO

 CREATE VIEW vw_TextAnswersPendingReview AS
SELECT 
    a.AnswerID,
    s.StudentID,
    s.FullName AS StudentName,
    q.QuestionID,
    q.QuestionText,
    q.BestAcceptedAnswer,
    a.AnswerText
FROM dbo.Answer a
JOIN dbo.Student s   ON a.StudentID = s.StudentID
JOIN dbo.Question q  ON a.QuestionID = q.QuestionID
WHERE q.QuestionType = 'Text'
  AND a.IsCorrect     IS NULL;
GO

 CREATE VIEW vw_StudentExamResults AS
SELECT 
    es.StudentID,
    s.FullName,
    e.ExamID,
    c.CourseName,
    SUM(a.ScoreAwarded) AS ScoreObtained,
    e.TotalDegree
FROM dbo.ExamStudent es
JOIN dbo.Student s     ON es.StudentID = s.StudentID
JOIN dbo.Exam e        ON es.ExamID    = e.ExamID
JOIN dbo.Answer a      ON es.ExamID = a.ExamID
                      AND es.StudentID = a.StudentID
JOIN dbo.Course c      ON e.CourseID = c.CourseID
GROUP BY es.StudentID, s.FullName, e.ExamID, c.CourseName, e.TotalDegree;
GO

 
CREATE PROCEDURE sp_CreateExam
    @CourseID           INT,
    @InstructorID       INT,
    @ExamType           NVARCHAR(20),
    @IntakeID           INT,
    @BranchID           INT,
    @TrackID            INT,
    @StartTime          DATETIME2,
    @EndTime            DATETIME2,
    @TotalTimeMinutes   INT,
    @AllowanceOptions   NVARCHAR(500),
    @ExamID             INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Exam
      (CourseID,InstructorID,ExamType,IntakeID,BranchID,TrackID,StartTime,EndTime,TotalTimeMinutes,AllowanceOptions,TotalDegree)
    VALUES
      (@CourseID,@InstructorID,@ExamType,@IntakeID,@BranchID,@TrackID,@StartTime,@EndTime,@TotalTimeMinutes,@AllowanceOptions,0);

    SET @ExamID = SCOPE_IDENTITY();
END;
GO

 CREATE PROCEDURE sp_AddExamQuestion
    @ExamID            INT,
    @QuestionID        INT,
    @DegreePerQuestion INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ExamQuestion (ExamID,QuestionID,DegreePerQuestion)
    VALUES (@ExamID,@QuestionID,@DegreePerQuestion);

    UPDATE e
       SET TotalDegree = (SELECT SUM(DegreePerQuestion)
                            FROM dbo.ExamQuestion
                           WHERE ExamID = @ExamID)
    FROM dbo.Exam e
    WHERE e.ExamID = @ExamID;
END;
GO

 CREATE FUNCTION dbo.fn_TextAnswerMatches
(
    @Answer NVARCHAR(MAX),
    @Pattern NVARCHAR(500)  -- SQL LIKE wildcard: e.g. '%keyword1%keyword2%'
)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @Answer LIKE @Pattern THEN 1 ELSE 0 END;
END;
GO

CREATE PROCEDURE sp_SearchExams
    @CourseID  INT = NULL,
    @BranchID  INT = NULL,
    @StartDate DATE = NULL
AS
BEGIN
    SELECT *
      FROM dbo.Exam
     WHERE (@CourseID IS NULL OR CourseID = @CourseID)
       AND (@BranchID IS NULL OR BranchID = @BranchID)
       AND (@StartDate IS NULL OR StartTime >= @StartDate);
END;
GO

 
USE msdb;
GO

 EXEC dbo.sp_add_job 
    @job_name = N'ExamSys_DailyBackup', 
    @enabled  = 1,
    @description = N'Daily full backup of ExaminationSystem at 2:00 AM';

 EXEC dbo.sp_add_jobstep
    @job_name = N'ExamSys_DailyBackup',
    @step_name = N'FullBackup',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE ExaminationSystem 
                  TO DISK = N''C:\SQLBackups\ExaminationSystem_Full.bak'' 
                  WITH FORMAT, INIT, NAME = ''Full Backup ExaminationSystem'';',
    @retry_attempts = 2,
    @retry_interval = 5;

 EXEC dbo.sp_add_schedule
    @schedule_name = N'ExamSys_DailySchedule',
    @freq_type     = 4,        -- daily
    @freq_interval = 1,        -- every day
    @active_start_time = 020000; -- 02:00:00

EXEC dbo.sp_attach_schedule
    @job_name     = N'ExamSys_DailyBackup',
    @schedule_name= N'ExamSys_DailySchedule';

EXEC dbo.sp_add_jobserver
    @job_name = N'ExamSys_DailyBackup',
    @server_name = N'(LOCAL)';
GO

 
 

 
