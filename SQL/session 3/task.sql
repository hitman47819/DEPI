CREATE DATABASE depi;
GO

USE depi;
GO


-- Create Department table
CREATE TABLE Department (
    DEPNum INT PRIMARY KEY,
    DEPName NVARCHAR(100) NOT NULL UNIQUE,
    Location NVARCHAR(100) NOT NULL,
    ManagerSSN INT UNIQUE
);
GO

-- Create Employee table
CREATE TABLE Employee (
    SSN INT PRIMARY KEY,
    FName NVARCHAR(50) NOT NULL,
    LName NVARCHAR(50) NOT NULL,
    Birthdate DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Supervisor_SSN INT NULL,
    DEPNum INT NOT NULL,
    FOREIGN KEY (Supervisor_SSN) REFERENCES Employee(SSN) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Add foreign key for ManagerSSN after Employee is created
ALTER TABLE Department
ADD CONSTRAINT FK_Department_Manager
FOREIGN KEY (ManagerSSN) REFERENCES Employee(SSN) ON DELETE SET NULL ON UPDATE CASCADE;
GO

-- Create Project table (each project belongs to one department)
CREATE TABLE Project (
    PNumber INT PRIMARY KEY,
    PName NVARCHAR(100) NOT NULL,
    Location_City NVARCHAR(100) NOT NULL,
    DEPNum INT NOT NULL,
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Create Dependent table (dependent of an employee)
CREATE TABLE Dependent (
    Dependent_Name NVARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Birthdate DATE NOT NULL,
    Employee_SSN INT NOT NULL,
    PRIMARY KEY (Employee_SSN, Dependent_Name),
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Create Works_On table (M:N relation between employees and projects)
CREATE TABLE Works_On (
    SSN INT NOT NULL,
    PNumber INT NOT NULL,
    Hours_Worked INT NOT NULL CHECK (Hours_Worked >= 0),
    PRIMARY KEY (SSN, PNumber),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PNumber) REFERENCES Project(PNumber) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Demonstrate ALTER TABLE by adding a column
ALTER TABLE Employee
ADD HireDate DATE DEFAULT GETDATE();
GO

-- Demonstrate ALTER TABLE by modifying a column's data type
ALTER TABLE Employee
ALTER COLUMN HireDate DATETIME;
GO

-- Demonstrate ALTER TABLE by dropping a constraint
-- Assume we drop the unique constraint from Department name for demonstration
ALTER TABLE Department
DROP CONSTRAINT UQ__Department__DEPName;
GO

-- Re-add it to keep integrity
ALTER TABLE Department
ADD CONSTRAINT UQ_Department_DEPName UNIQUE (DEPName);
GO
-- Insert departments
INSERT INTO Department (DEPNum, DEPName, Location)
VALUES 
(1, N'IT', N'Cairo'),
(2, N'HR', N'Alexandria');
GO

-- Insert employees
INSERT INTO Employee (SSN, FName, LName, Birthdate, Gender, Supervisor_SSN, DEPNum, HireDate)
VALUES 
(1001, N'Ahmed', N'Gamal', '1990-05-20', 'M', NULL, 1, '2018-01-01'),
(1002, N'Sara', N'Mahmoud', '1992-08-14', 'F', 1001, 1, '2019-03-15'),
(1003, N'Mostafa', N'Hassan', '1985-12-10', 'M', 1001, 2, '2020-07-01');
GO

-- Update departments to assign managers
UPDATE Department SET ManagerSSN = 1001 WHERE DEPNum = 1;
UPDATE Department SET ManagerSSN = 1003 WHERE DEPNum = 2;
GO

-- Insert projects
INSERT INTO Project (PNumber, PName, Location_City, DEPNum)
VALUES 
(201, N'Payroll System', N'Cairo', 1),
(202, N'Attendance Tracker', N'Alexandria', 2);
GO

-- Insert dependents
INSERT INTO Dependent (Dependent_Name, Gender, Birthdate, Employee_SSN)
VALUES 
(N'Omar', 'M', '2015-06-01', 1001),
(N'Laila', 'F', '2018-09-15', 1002);
GO

-- Insert works_on data
INSERT INTO Works_On (SSN, PNumber, Hours_Worked)
VALUES 
(1001, 201, 20),
(1002, 201, 15),
(1002, 202, 10),
(1003, 202, 25);
GO
