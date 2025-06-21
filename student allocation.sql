CREATE DATABASE CollegeElectiveDB;
GO

USE CollegeElectiveDB;
GO

CREATE TABLE StudentDetails (
    StudentId INT PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(10),
    Section CHAR(1)
);

CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

CREATE TABLE StudentPreference (
    StudentId INT,
    SubjectId VARCHAR(10),
    Preference INT,
    PRIMARY KEY (StudentId, Preference),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId INT,
    PRIMARY KEY (SubjectId, StudentId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

CREATE TABLE UnallotedStudents (
    StudentId INT PRIMARY KEY,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);


INSERT INTO StudentDetails VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Sohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'C'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE', 'B');

INSERT INTO SubjectDetails VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Ace philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

INSERT INTO StudentPreference VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5);


GO
CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentList TABLE (
        StudentId INT,
        GPA FLOAT
    );

    INSERT INTO @StudentList (StudentId, GPA)
    SELECT StudentId, GPA
    FROM StudentDetails
    ORDER BY GPA DESC;

    DECLARE @StudentId INT;
    DECLARE @Preference INT;
    DECLARE @SubjectId VARCHAR(10);
    DECLARE @RemainingSeats INT;

    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM @StudentList;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Preference = 1;

        WHILE @Preference <= 5
        BEGIN
            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            IF @SubjectId IS NULL
            BEGIN
                SET @Preference = @Preference + 1;
                CONTINUE;
            END

            SELECT @RemainingSeats = RemainingSeats
            FROM SubjectDetails
            WHERE SubjectId = @SubjectId;

            IF @RemainingSeats > 0
            BEGIN
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (@SubjectId, @StudentId);

                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;

                BREAK;
            END

            SET @Preference = @Preference + 1;
        END

        IF @Preference > 5
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END


EXEC AllocateSubjects;

SELECT * FROM Allotments;
SELECT * FROM UnallotedStudents;
SELECT * FROM SubjectDetails;
SELECT * FROM StudentPreference;
