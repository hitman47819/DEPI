CREATE DATABASE depi;
USE depi;

CREATE TABLE Department (
    DEPNum INT PRIMARY KEY,
    DEPName NVARCHAR(100),
    Location NVARCHAR(100)
);

CREATE TABLE Employee (
    SSN INT PRIMARY KEY,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    Birthdate DATE,
    Gender CHAR(1),
    Supervisor_SSN INT,
    DEPNum INT,
    FOREIGN KEY (Supervisor_SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum)
);

CREATE TABLE Project (
    PNumber INT PRIMARY KEY,
    PName NVARCHAR(100),
    Location_City NVARCHAR(100)
);

CREATE TABLE Dependent (
    Dependent_Name NVARCHAR(50),
    Gender CHAR(1),
    Birthdate DATE,
    Employee_SSN INT,
    PRIMARY KEY (Employee_SSN, Dependent_Name),
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN) ON DELETE CASCADE
);

CREATE TABLE Works_On (
    SSN INT,
    PNumber INT,
    Hours_Worked INT,
    PRIMARY KEY (SSN, PNumber),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (PNumber) REFERENCES Project(PNumber)
);

CREATE TABLE Manages (
    SSN INT,
    DEPNum INT,
    Hire_Date DATE,
    PRIMARY KEY (SSN, DEPNum),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum)
);

CREATE TABLE Dependents_Of (
    SSN INT,
    Dependent_Name NVARCHAR(50),
    PRIMARY KEY (SSN, Dependent_Name),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (SSN, Dependent_Name) REFERENCES Dependent(Employee_SSN, Dependent_Name)
);


INSERT INTO Department VALUES
(1, N'IT', N'Cairo'),
(2, N'HR', N'Alexandria');

INSERT INTO Employee VALUES
(1001, N'Ahmed', N'Gamal', '1990-05-20', 'M', NULL, 1),
(1002, N'Sara', N'Mahmoud', '1992-08-14', 'F', 1001, 1),
(1003, N'Mostafa', N'Hassan', '1985-12-10', 'M', 1001, 2);

INSERT INTO Project VALUES
(201, N'Payroll System', N'Cairo'),
(202, N'Attendance Tracker', N'Alexandria');

INSERT INTO Dependent VALUES
(N'Omar', 'M', '2015-06-01', 1001),
(N'Laila', 'F', '2018-09-15', 1002);

INSERT INTO Works_On VALUES
(1001, 201, 20),
(1002, 201, 15),
(1002, 202, 10),
(1003, 202, 25);

INSERT INTO Manages VALUES
(1001, 1, '2020-01-01'),
(1003, 2, '2021-06-01');

INSERT INTO Dependents_Of VALUES
(1001, N'Omar'),
(1002, N'Laila');

