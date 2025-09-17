

SET NOCOUNT ON;
GO

USE master;
GO
IF DB_ID(N'ExaminationSystem') IS NOT NULL
BEGIN
    ALTER DATABASE ExaminationSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ExaminationSystem;
END
GO

CREATE DATABASE ExaminationSystem
GO


USE master;
GO
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ES_Admin') DROP LOGIN ES_Admin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ES_Manager') DROP LOGIN ES_Manager;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ES_Instructor') DROP LOGIN ES_Instructor;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ES_Student') DROP LOGIN ES_Student;
GO

CREATE LOGIN ES_Admin       WITH PASSWORD = 'P@ssw0rdAdmin!';
CREATE LOGIN ES_Manager     WITH PASSWORD = 'P@ssw0rdManager!';
CREATE LOGIN ES_Instructor  WITH PASSWORD = 'P@ssw0rdInstr!';
CREATE LOGIN ES_Student     WITH PASSWORD = 'P@ssw0rdStud!';
GO

USE ExaminationSystem;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ES_Admin') DROP USER ES_Admin;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ES_Manager') DROP USER ES_Manager;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ES_Instructor') DROP USER ES_Instructor;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ES_Student') DROP USER ES_Student;
GO

CREATE USER ES_Admin       FOR LOGIN ES_Admin WITH DEFAULT_SCHEMA = dbo;
CREATE USER ES_Manager     FOR LOGIN ES_Manager WITH DEFAULT_SCHEMA = dbo;
CREATE USER ES_Instructor  FOR LOGIN ES_Instructor WITH DEFAULT_SCHEMA = dbo;
CREATE USER ES_Student     FOR LOGIN ES_Student WITH DEFAULT_SCHEMA = dbo;
GO
IF TYPE_ID(N'dbo.IntList') IS NOT NULL DROP TYPE dbo.IntList;
GO
CREATE TYPE dbo.IntList AS TABLE(Item INT);
GO

-- Drop tables in dependency order
IF OBJECT_ID('dbo.ExamResults','U') IS NOT NULL DROP TABLE dbo.ExamResults;
IF OBJECT_ID('dbo.Answer','U') IS NOT NULL DROP TABLE dbo.Answer;
IF OBJECT_ID('dbo.ExamStudent','U') IS NOT NULL DROP TABLE dbo.ExamStudent;
IF OBJECT_ID('dbo.ExamQuestion','U') IS NOT NULL DROP TABLE dbo.ExamQuestion;
IF OBJECT_ID('dbo.Exam','U') IS NOT NULL DROP TABLE dbo.Exam;
IF OBJECT_ID('dbo.MultipleChoiceOption','U') IS NOT NULL DROP TABLE dbo.MultipleChoiceOption;
IF OBJECT_ID('dbo.Question','U') IS NOT NULL DROP TABLE dbo.Question;
IF OBJECT_ID('dbo.Course','U') IS NOT NULL DROP TABLE dbo.Course;
IF OBJECT_ID('dbo.Student','U') IS NOT NULL DROP TABLE dbo.Student;
IF OBJECT_ID('dbo.Instructor','U') IS NOT NULL DROP TABLE dbo.Instructor;
IF OBJECT_ID('dbo.Intake','U') IS NOT NULL DROP TABLE dbo.Intake;
IF OBJECT_ID('dbo.Track','U') IS NOT NULL DROP TABLE dbo.Track;
IF OBJECT_ID('dbo.Branch','U') IS NOT NULL DROP TABLE dbo.Branch;
IF OBJECT_ID('dbo.UserAccount','U') IS NOT NULL DROP TABLE dbo.UserAccount;
GO

CREATE TABLE dbo.UserAccount (
    UserID       INT IDENTITY(1,1) PRIMARY KEY,
    Username     SYSNAME NOT NULL UNIQUE,
    PasswordHash VARBINARY(8000) NOT NULL,
    Role         NVARCHAR(50) NOT NULL
        CONSTRAINT CHK_User_Role CHECK (Role IN ('Admin','Manager','Instructor','Student'))
);

CREATE TABLE dbo.Branch (
    BranchID   INT IDENTITY(1,1) PRIMARY KEY,
    BranchName NVARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE dbo.Track (
    TrackID   INT IDENTITY(1,1) PRIMARY KEY,
    TrackName NVARCHAR(200) NOT NULL,
    BranchID  INT NOT NULL REFERENCES dbo.Branch(BranchID),
    CONSTRAINT UQ_Track_Per_Branch UNIQUE(BranchID,TrackName)
);

CREATE TABLE dbo.Intake (
    IntakeID   INT IDENTITY(1,1) PRIMARY KEY,
    IntakeName NVARCHAR(100) NOT NULL UNIQUE,
    StartDate  DATE NOT NULL,
    EndDate    DATE NOT NULL
);

CREATE TABLE dbo.Instructor (
    InstructorID INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT NOT NULL REFERENCES dbo.UserAccount(UserID),
    FullName     NVARCHAR(200) NOT NULL,
    Email        NVARCHAR(320) NOT NULL UNIQUE
);

CREATE TABLE dbo.Student (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    UserID    INT NOT NULL REFERENCES dbo.UserAccount(UserID),
    FullName  NVARCHAR(200) NOT NULL,
    Email     NVARCHAR(320) NOT NULL UNIQUE,
    BranchID  INT NOT NULL REFERENCES dbo.Branch(BranchID),
    TrackID   INT NOT NULL REFERENCES dbo.Track(TrackID),
    IntakeID  INT NOT NULL REFERENCES dbo.Intake(IntakeID)
);

CREATE TABLE dbo.Course (
    CourseID     INT IDENTITY(1,1) PRIMARY KEY,
    CourseName   NVARCHAR(200) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    MaxDegree    INT NOT NULL CHECK (MaxDegree > 0),
    MinDegree    INT NOT NULL,
    InstructorID INT NOT NULL REFERENCES dbo.Instructor(InstructorID),
    BranchID     INT NOT NULL REFERENCES dbo.Branch(BranchID),
    TrackID      INT NOT NULL REFERENCES dbo.Track(TrackID),
    IntakeID     INT NOT NULL REFERENCES dbo.Intake(IntakeID),
    CONSTRAINT UQ_Course_Per_Cohort UNIQUE(BranchID,TrackID,IntakeID,CourseName),
    CONSTRAINT CHK_Min_vs_Max CHECK (MinDegree >= 0 AND MinDegree < MaxDegree)
);

CREATE TABLE dbo.Question (
    QuestionID         INT IDENTITY(1,1) PRIMARY KEY,
    CourseID           INT NOT NULL REFERENCES dbo.Course(CourseID),
    QuestionText       NVARCHAR(MAX) NOT NULL,
    QuestionType       NVARCHAR(20) NOT NULL
        CONSTRAINT CHK_Question_Type CHECK (QuestionType IN ('MultipleChoice','TrueFalse','Text')),
    CorrectAnswerText  NVARCHAR(MAX) NULL,
    BestAcceptedAnswer NVARCHAR(MAX) NULL
);

CREATE TABLE dbo.MultipleChoiceOption (
    OptionID   INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID INT NOT NULL REFERENCES dbo.Question(QuestionID),
    OptionText NVARCHAR(500) NOT NULL,
    IsCorrect  BIT NOT NULL
);

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
);

CREATE TABLE dbo.ExamQuestion (
    ExamID            INT NOT NULL REFERENCES dbo.Exam(ExamID),
    QuestionID        INT NOT NULL REFERENCES dbo.Question(QuestionID),
    DegreePerQuestion INT NOT NULL CHECK (DegreePerQuestion > 0),
    PRIMARY KEY (ExamID,QuestionID)
);

CREATE TABLE dbo.ExamStudent (
    ExamID    INT NOT NULL REFERENCES dbo.Exam(ExamID),
    StudentID INT NOT NULL REFERENCES dbo.Student(StudentID),
    ExamDate  DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime   TIME NOT NULL,
    PRIMARY KEY (ExamID,StudentID)
);

CREATE TABLE dbo.Answer (
    AnswerID     INT IDENTITY(1,1) PRIMARY KEY,
    ExamID       INT NOT NULL REFERENCES dbo.Exam(ExamID),
    QuestionID   INT NOT NULL REFERENCES dbo.Question(QuestionID),
    StudentID    INT NOT NULL REFERENCES dbo.Student(StudentID),
    AnswerText   NVARCHAR(MAX) NOT NULL,
    IsCorrect    BIT NULL,
    ScoreAwarded INT NULL,
    ResultStored BIT NOT NULL DEFAULT(0)
);

CREATE TABLE dbo.ExamResults (
    ExamID       INT NOT NULL REFERENCES dbo.Exam(ExamID),
    StudentID    INT NOT NULL REFERENCES dbo.Student(StudentID),
    ScoreObtained INT NOT NULL,
    DateFinalized DATETIME2 DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (ExamID, StudentID)
);
GO

CREATE INDEX IX_Answer_Exam_Student
    ON dbo.Answer (ExamID, StudentID);

CREATE INDEX IX_Exam_Course
    ON dbo.Exam (CourseID);

CREATE INDEX IX_Question_By_CourseType
    ON dbo.Question (CourseID, QuestionType);
GO




IF OBJECT_ID('trg_Exam_TotalDegree','TR') IS NOT NULL DROP TRIGGER trg_Exam_TotalDegree;
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
        RAISERROR('TotalDegree exceeds Course.MaxDegree.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

IF OBJECT_ID('trg_Answer_AutoScore','TR') IS NOT NULL DROP TRIGGER trg_Answer_AutoScore;
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



IF OBJECT_ID('vw_TextAnswersPendingReview','V') IS NOT NULL DROP VIEW vw_TextAnswersPendingReview;
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

IF OBJECT_ID('vw_StudentExamResults','V') IS NOT NULL DROP VIEW vw_StudentExamResults;
GO
CREATE VIEW vw_StudentExamResults AS
SELECT 
    es.StudentID,
    s.FullName,
    e.ExamID,
    c.CourseName,
    ISNULL(SUM(a.ScoreAwarded),0) AS ScoreObtained,
    e.TotalDegree
FROM dbo.ExamStudent es
JOIN dbo.Student s     ON es.StudentID = s.StudentID
JOIN dbo.Exam e        ON es.ExamID    = e.ExamID
LEFT JOIN dbo.Answer a  ON es.ExamID = a.ExamID
                      AND es.StudentID = a.StudentID
JOIN dbo.Course c      ON e.CourseID = c.CourseID
GROUP BY es.StudentID, s.FullName, e.ExamID, c.CourseName, e.TotalDegree;
GO



IF OBJECT_ID('dbo.fn_NormalizeText','FN') IS NOT NULL DROP FUNCTION dbo.fn_NormalizeText;
GO
CREATE FUNCTION dbo.fn_NormalizeText(@txt NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @r NVARCHAR(MAX) = COALESCE(@txt,'');
  SET @r = LTRIM(RTRIM(@r));
  SET @r = LOWER(@r);
  SET @r = TRANSLATE(@r, N'.,;:!?()[]{}"''`-', N'                         ');
  SET @r = REPLACE(@r, CHAR(13), ' ');
  SET @r = REPLACE(@r, CHAR(10), ' ');
  WHILE CHARINDEX('  ',@r) > 0 SET @r = REPLACE(@r,'  ',' ');
  RETURN @r;
END;
GO

IF OBJECT_ID('dbo.fn_TextAnswerMatches','FN') IS NOT NULL DROP FUNCTION dbo.fn_TextAnswerMatches;
GO
CREATE FUNCTION dbo.fn_TextAnswerMatches
(
    @Answer NVARCHAR(MAX),
    @Pattern NVARCHAR(500)  
)
RETURNS BIT
AS
BEGIN
    IF dbo.fn_NormalizeText(@Answer) LIKE dbo.fn_NormalizeText(@Pattern) RETURN 1;
    RETURN 0;
END;
GO



IF OBJECT_ID('dbo.sp_CreateExam','P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateExam;
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

IF OBJECT_ID('dbo.sp_AddExamQuestion','P') IS NOT NULL DROP PROCEDURE dbo.sp_AddExamQuestion;
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
       SET TotalDegree = (SELECT ISNULL(SUM(DegreePerQuestion),0)
                            FROM dbo.ExamQuestion
                           WHERE ExamID = @ExamID)
    FROM dbo.Exam e
    WHERE e.ExamID = @ExamID;
END;
GO

IF OBJECT_ID('dbo.sp_PickRandomQuestions','P') IS NOT NULL DROP PROCEDURE dbo.sp_PickRandomQuestions;
GO
CREATE PROCEDURE dbo.sp_PickRandomQuestions
  @CourseID INT,
  @QuestionType NVARCHAR(20),
  @Count INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP(@Count) QuestionID
  FROM dbo.Question
  WHERE CourseID = @CourseID
    AND QuestionType = @QuestionType
  ORDER BY NEWID();
END;
GO

IF OBJECT_ID('dbo.sp_AssignStudentsToExam','P') IS NOT NULL DROP PROCEDURE dbo.sp_AssignStudentsToExam;
GO
CREATE PROCEDURE dbo.sp_AssignStudentsToExam
  @ExamID INT,
  @StudentIDs dbo.IntList READONLY
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Start DATETIME2 = (SELECT StartTime FROM dbo.Exam WHERE ExamID=@ExamID);
  DECLARE @End   DATETIME2 = (SELECT EndTime   FROM dbo.Exam WHERE ExamID=@ExamID);

  INSERT INTO dbo.ExamStudent(ExamID, StudentID, ExamDate, StartTime, EndTime)
  SELECT @ExamID, v.Item, CONVERT(date,@Start), CONVERT(time,@Start), CONVERT(time,@End)
  FROM @StudentIDs v
  WHERE NOT EXISTS (SELECT 1 FROM dbo.ExamStudent es WHERE es.ExamID=@ExamID AND es.StudentID=v.Item);
END;
GO

IF OBJECT_ID('dbo.sp_CanStudentStartExam','P') IS NOT NULL DROP PROCEDURE dbo.sp_CanStudentStartExam;
GO
CREATE PROCEDURE dbo.sp_CanStudentStartExam
  @ExamID INT,
  @StudentID INT,
  @CanStart BIT OUTPUT,
  @Reason NVARCHAR(250) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Now DATETIME2 = SYSUTCDATETIME();

  IF NOT EXISTS (SELECT 1 FROM dbo.ExamStudent WHERE ExamID=@ExamID AND StudentID=@StudentID)
  BEGIN
    SET @CanStart = 0; SET @Reason = 'Student not assigned to this exam.'; RETURN;
  END

  DECLARE @Start DATETIME2 = (SELECT StartTime FROM dbo.Exam WHERE ExamID=@ExamID);
  DECLARE @End   DATETIME2 = (SELECT EndTime   FROM dbo.Exam WHERE ExamID=@ExamID);

  IF @Now < @Start
  BEGIN SET @CanStart = 0; SET @Reason = 'Exam has not started yet.'; RETURN; END
  IF @Now > @End
  BEGIN SET @CanStart = 0; SET @Reason = 'Exam has already ended.'; RETURN; END

  SET @CanStart = 1; SET @Reason = 'OK';
END;
GO

IF OBJECT_ID('dbo.sp_FinalizeExamResults','P') IS NOT NULL DROP PROCEDURE dbo.sp_FinalizeExamResults;
GO
CREATE PROCEDURE dbo.sp_FinalizeExamResults
  @ExamID INT
AS
BEGIN
  SET NOCOUNT ON;

  MERGE dbo.ExamResults AS tgt
  USING (
    SELECT a.StudentID, SUM(ISNULL(a.ScoreAwarded,0)) AS ScoreObtained
    FROM dbo.Answer a
    WHERE a.ExamID = @ExamID
    GROUP BY a.StudentID
  ) AS src (StudentID, ScoreObtained)
  ON tgt.ExamID = @ExamID AND tgt.StudentID = src.StudentID
  WHEN MATCHED THEN UPDATE SET ScoreObtained = src.ScoreObtained, DateFinalized = SYSUTCDATETIME()
  WHEN NOT MATCHED THEN
    INSERT (ExamID, StudentID, ScoreObtained) VALUES (@ExamID, src.StudentID, src.ScoreObtained);
END;
GO


DELETE FROM dbo.Answer;
DELETE FROM dbo.Exam;

TRUNCATE TABLE dbo.ExamResults;
 TRUNCATE TABLE dbo.ExamStudent;
TRUNCATE TABLE dbo.ExamQuestion;
 TRUNCATE TABLE dbo.MultipleChoiceOption;
TRUNCATE TABLE dbo.Question;
TRUNCATE TABLE dbo.Course;
TRUNCATE TABLE dbo.Student;
TRUNCATE TABLE dbo.Instructor;
TRUNCATE TABLE dbo.Intake;
TRUNCATE TABLE dbo.Track;
TRUNCATE TABLE dbo.Branch;
TRUNCATE TABLE dbo.UserAccount;
GO

INSERT INTO dbo.UserAccount(Username, PasswordHash, Role)
VALUES 
('admin@es.local', HASHBYTES('SHA2_512','P@ssw0rdAdmin!'), 'Admin'),
('manager@es.local', HASHBYTES('SHA2_512','P@ssw0rdManager!'), 'Manager'),
('instr1@es.local', HASHBYTES('SHA2_512','P@ssw0rdInstr!'), 'Instructor'),
('student1@es.local', HASHBYTES('SHA2_512','P@ssw0rdStud!'), 'Student');
GO

INSERT INTO dbo.Branch(BranchName) VALUES ('Main Branch');
INSERT INTO dbo.Track(BranchID, TrackName) VALUES (1, 'Software');
INSERT INTO dbo.Intake(IntakeName, StartDate, EndDate) VALUES ('2025 Spring', '2025-02-01','2025-06-30');
GO

DECLARE @InstrUserID INT = (SELECT UserID FROM dbo.UserAccount WHERE Username='instr1@es.local');
DECLARE @StudUserID  INT = (SELECT UserID FROM dbo.UserAccount WHERE Username='student1@es.local');
INSERT INTO dbo.Instructor(UserID, FullName, Email) VALUES (@InstrUserID, 'Ahmed Instructor', 'instr1@es.local');
INSERT INTO dbo.Student(UserID, FullName, Email, BranchID, TrackID, IntakeID) 
VALUES (@StudUserID, 'Mohamed Student', 'student1@es.local', 1, 1, 1);
GO

INSERT INTO dbo.Course(CourseName, Description, MaxDegree, MinDegree, InstructorID, BranchID, TrackID, IntakeID)
VALUES ('Database Systems', 'Intro to databases', 100, 0, 1, 1, 1, 1);
GO

INSERT INTO dbo.Question(CourseID, QuestionText, QuestionType, CorrectAnswerText, BestAcceptedAnswer)
VALUES 
(1, 'What is SQL?', 'Text', NULL, 'structured query language'),
(1, '2 + 2 = 4 ?', 'TrueFalse', 'True', NULL),
(1, 'Which is a primary key?', 'MultipleChoice', 'Option A', NULL);
GO

INSERT INTO dbo.MultipleChoiceOption(QuestionID, OptionText, IsCorrect)
VALUES (3,'Option A',1),(3,'Option B',0),(3,'Option C',0),(3,'Option D',0);
GO



EXEC sp_addrolemember 'db_owner', 'ES_Admin';
EXEC sp_addrolemember 'db_ddladmin', 'ES_Manager';
GO

GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Branch TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Track  TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Intake TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Student TO ES_Manager;
GRANT INSERT, UPDATE, DELETE, SELECT ON dbo.Course  TO ES_Manager;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_CreateExam       TO ES_Instructor;
GRANT EXECUTE ON OBJECT::dbo.sp_AddExamQuestion  TO ES_Instructor;
GRANT EXECUTE ON OBJECT::dbo.sp_PickRandomQuestions TO ES_Instructor;
GRANT SELECT  ON dbo.vw_TextAnswersPendingReview TO ES_Instructor;
GRANT SELECT  ON dbo.vw_StudentExamResults       TO ES_Instructor;
GRANT INSERT, SELECT ON dbo.Answer                TO ES_Instructor; 
GO

GRANT SELECT  ON dbo.vw_StudentExamResults TO ES_Student;
GRANT INSERT, SELECT ON dbo.Answer            TO ES_Student;
GO


BEGIN TRY
    USE msdb;
    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'ExamSys_DailyBackup')
    BEGIN
        EXEC dbo.sp_delete_job @job_name = N'ExamSys_DailyBackup';
    END

    EXEC dbo.sp_add_job 
        @job_name = N'ExamSys_DailyBackup', 
        @enabled  = 1,
        @description = N'Daily full backup of ExaminationSystem at 02:00 AM';

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
END TRY
BEGIN CATCH
    PRINT 'Warning: could not create SQL Agent job. SQL Agent may not be installed or permission denied.';
    PRINT ERROR_MESSAGE();
END CATCH
GO


SELECT * FROM dbo.vw_TextAnswersPendingReview;
SELECT * FROM dbo.vw_StudentExamResults;
GO

PRINT 'ExaminationSystem created successfully. Adjust file paths and job settings as needed.';
GO
 

