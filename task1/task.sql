CREATE TABLE Employee (
    SSN INT IDENTITY(0,1) PRIMARY KEY,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    Birthdate DATE,
    Gender CHAR(1),
    Supervisor_SSN INT NULL,
    FOREIGN KEY (Supervisor_SSN) REFERENCES Employee(SSN)
);

CREATE TABLE Department (
    DEPNum INT PRIMARY KEY,
    DEPName NVARCHAR(50),
    Location NVARCHAR(100)
);

CREATE TABLE Project (
    PNumber INT PRIMARY KEY,
    PName NVARCHAR(50),
    Location_City NVARCHAR(100)
);

CREATE TABLE Dependent (
    Dependent_Name NVARCHAR(50) PRIMARY KEY,
    Gender CHAR(1),
    Birthdate DATE,
    Employee_SSN INT,
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
);

CREATE TABLE Dependents_Of (
    SSN INT,
    Dependent_Name NVARCHAR(50),
    PRIMARY KEY (SSN, Dependent_Name),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (Dependent_Name) REFERENCES Dependent(Dependent_Name)
);

CREATE TABLE Works_In (
    SSN INT,
    DEPNum INT,
    PRIMARY KEY (SSN, DEPNum),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum)
);

CREATE TABLE Works_On (
    DEPNum INT,
    PNumber INT,
    Hours_Worked INT,
    PRIMARY KEY (DEPNum, PNumber),
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum),
    FOREIGN KEY (PNumber) REFERENCES Project(PNumber)
);

-- 8. Create MANAGES table
CREATE TABLE Manages (
    SSN INT,
    DEPNum INT,
    Hire_Date DATE,
    PRIMARY KEY (SSN, DEPNum),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN),
    FOREIGN KEY (DEPNum) REFERENCES Department(DEPNum)
);

INSERT INTO Department VALUES 
(10, 'IT', 'Cairo'),
(20, 'HR', 'Alexandria'),
(30, 'Finance', 'Mansoura');

INSERT INTO Employee (FName, LName, Birthdate, Gender, Supervisor_SSN) VALUES
(N'Ahmed', N'Saad', '1985-01-01', 'M', NULL),     
(N'Salma', N'Fahmy', '1990-02-02', 'F', 0),        
(N'Mohamed', N'Gamal', '1988-03-03', 'M', 0),      
(N'Nour', N'ElSherif', '1975-04-04', 'F', 1),      
(N'Omar', N'Reda', '1992-05-05', 'M', 1);          

INSERT INTO Project VALUES 
(1001, N'AI Project', 'Cairo'),
(1002, N'HR System'', 'Alexandria'),
(1003, N'Payroll Automation', 'Mansoura');

INSERT INTO Works_In VALUES
(0, 10),  -- Ahmed → IT in Cairo
(1, 10),  -- Salma → IT in Cairo
(2, 20),  -- Mohamed → HR in Alexandria
(3, 30),  -- Nour → Finance in Mansoura
(4, 30);  -- Omar → Finance in Mansoura

INSERT INTO Dependent VALUES
(N'Youssef', 'M', '2010-01-01', 0),
(N'Menna', 'F', '2012-03-05', 1);

INSERT INTO Dependents_Of VALUES
(0, N'Youssef'),
(1, N'Menna');

INSERT INTO Works_On VALUES
(10, 1001, 40),
(20, 1002, 20),
(30, 1003, 35);

INSERT INTO Manages VALUES
(0, 10, '2020-01-01'),  -- Ahmed manages IT
(2, 20, '2021-06-01');  -- Mohamed manages HR

UPDATE Works_In SET DEPNum = 20 WHERE SSN = 4;

DELETE FROM Dependents_Of WHERE Dependent_Name = N'Menna' AND SSN = 1;
DELETE FROM Dependent WHERE Dependent_Name = N'Menna';

SELECT E.*
FROM Employee E
JOIN Works_In W ON E.SSN = W.SSN
WHERE W.DEPNum = 10;

SELECT E.FName, E.LName, P.PName, W.Hours_Worked
FROM Employee E
JOIN Works_In WI ON E.SSN = WI.SSN
JOIN Works_On W ON WI.DEPNum = W.DEPNum
JOIN Project P ON W.PNumber = P.PNumber;