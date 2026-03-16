/* 
   File: DatabaseDDL.sql
   Purpose: This file contains the DDL statements
        to create the database schema for the 3D Scanning Lab project. It defines the tables,
        their relationships, and inserts some initial data to demonstrate the functionality of the database.
   Author: Aspen Frazee and Alexander Hinson
   Created: 02-12-2026
   Last Update: 03-13-2026
*/

SET foreign_key_checks=0;
DROP TABLE IF EXISTS ScanPOCs;
DROP TABLE IF EXISTS 3DScans;
DROP TABLE IF EXISTS Artifacts;
DROP TABLE IF EXISTS Technicians;
DROP TABLE IF EXISTS PointsOfContact;

-- =================
-- TABLE DEFINITIONS
-- =================
CREATE TABLE PointsOfContact (
    pocID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT 1,
    pocFName VARCHAR(26) NOT NULL,
    pocLName VARCHAR(26) NOT NULL,
    pocEmail VARCHAR(51) NOT NULL,
    pocPhone VARCHAR(26) NOT NULL,
    pocInstitution VARCHAR(101) NOT NULL
);

CREATE TABLE Artifacts (
    artifactID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    pocID  INT(11) NOT NULL,
    onSite BOOLEAN NOT NULL DEFAULT TRUE,
    institutionID VARCHAR(101),
    location VARCHAR(50) NOT NULL,
    ipHolder VARCHAR(50),
    license VARCHAR(50),
    classification VARCHAR(50) NOT NULL,
    cultural BOOLEAN NOT NULL DEFAULT FALSE,
    archaeology BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (pocID) REFERENCES PointsOfContact(pocID)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Technicians (
    techID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    techFName VARCHAR(26) NOT NULL,
    techLName VARCHAR(26) NOT NULL,
    techEmail VARCHAR(51) NOT NULL,
    techPhone VARCHAR(26) NOT NULL
);

CREATE TABLE 3DScans (
    scanID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    labPOCID INT(11) NOT NULL,
    artifactID INT(11) NOT NULL,
    techID INT(11) NOT NULL,
    scanDate DATE NOT NULL,
    units VARCHAR(10) NOT NULL DEFAULT 'mm',
    scanMethod VARCHAR(50) NOT NULL,
    derived BOOLEAN NOT NULL DEFAULT FALSE,
    fileName VARCHAR (50) NOT NULL UNIQUE,
    FOREIGN KEY (artifactID) REFERENCES Artifacts(artifactID) 
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (labPOCID) REFERENCES PointsOfContact(pocID) 
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (techID) REFERENCES Technicians(techID) 
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- M:M intersection table between PointsOfContact and 3DScans.
CREATE TABLE ScanPOCs (
    scanPOCID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    pocID INT(11) NOT NULL,
    scanID INT(11) NOT NULL,
    FOREIGN KEY (pocID) REFERENCES PointsOfContact(pocID) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (scanID) REFERENCES 3DScans(scanID) 
    ON DELETE CASCADE ON UPDATE CASCADE
);

SET foreign_key_checks=1; -- Moved to after the drops by Copilot recommendation
-- ==================
-- INSERT DEFINITIONS
-- ==================

INSERT INTO PointsOfContact (
    active,
    pocFName, pocLName,
    pocEmail,
    pocPhone,
    pocInstitution
)
VALUES
(
    1,
    'Samwell', 'Tarly',
    'STarly@housetarly.com',
    '555-432-9876',
    'The Citadel Library'
),
(
    0,
    'Jaime', 'Lannister',
    'JLannister@houselannister.com',
    '222-543-6789',
    'Kings Landing'
),
(
    1,
    'Cersei', 'Lannister',
    'CLannister@houselannister.com',
    '222-543-6799',
    'Kings Landing'
),
(
    1,
    'Tyrion', 'Lannister',
    'TLannister@houselannister.com',
    '222-345-6789',
    'All around Westeros'
);

INSERT INTO Artifacts (
    pocID,
    onSite,
    institutionID,
    location,
    ipHolder,
    license,
    classification,
    cultural, archaeology
)
VALUES
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Jaime' AND pocLName = 'Lannister'),
    1,
    'Felis concolor',
    '3D Scanning Lab',
    'Pacific Slope Archaeological Laboratory',
    'CC BY-NC-SA 4.0',
    'Osteological',
    0, 1
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Cersei' AND pocLName = 'Lannister'),
    1,
    'CS191',
    '3D Scanning Lab',
    'Pacific Slope Archaeological Laboratory',
    'CC BY-NC-SA 4.0',
    'Osteological',
    0, 0
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Cersei' AND pocLName = 'Lannister'),
    0,
    NULL,
    'N/a',
    'Archaeomodels',
    'CC BY-SA',
    'Biface',
    1, 1
);

INSERT INTO Technicians (
    techFName, techLName,
    techEmail,
    techPhone
)
VALUES
(
    'Jon', 'Snow',
    'JSnow@housestark.com',
    '111-222-3333'
),
(
    'Arya', 'Stark',
    'AStark@housestark.com',
    '123-223-3334'
),
(
    'Sansa', 'Stark',
    'SStark@housestark.com',
    '321-233-3344'
);

INSERT INTO 3DScans (
    labPOCID,
    artifactID,
    techID,
    scanDate,
    scanMethod,
    derived,
    fileName
)
VALUES
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT artifactID FROM Artifacts 
        WHERE artifactID = 1),
    (SELECT techID FROM Technicians 
        WHERE techFName = 'Jon' AND techLName = 'Snow'),
    '20260106',
    'Structured Light',
    0,
    'feline_skull.obj'
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT artifactID FROM Artifacts 
        WHERE artifactID = 2),
    (SELECT techID FROM Technicians 
        WHERE techFName = 'Jon' AND techLName = 'Snow'),
    '20260113',
    'Structured Light',
    0,
    'vertebra_text.obj'
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT artifactID FROM Artifacts 
        WHERE artifactID = 2),
    (SELECT techID FROM Technicians 
        WHERE techFName = 'Arya' AND techLName = 'Stark'),
    '20260113',
    'Structured Light',
    1,
    'obsidian_biface.ply'
);

INSERT INTO ScanPOCs (
    pocID,
    scanID
)
VALUES
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Jaime' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans 
    WHERE fileName = 'feline_skull.obj')
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans 
        WHERE fileName = 'feline_skull.obj')
),
(
    (SELECT pocID FROM PointsOfContact 
        WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans 
        WHERE fileName = 'vertebra_text.obj')
);

COMMIT;