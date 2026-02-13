SET foreign_key_checks=0;
SET autocommit = 0;


--TABLE DEFINITIONS--

DROP TABLE IF EXISTS PointsOfContact;
CREATE TABLE PointsOfContact (
    pocID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT 1,
    pocFName VARCHAR(26) NOT NULL,
    pocLName VARCHAR(26) NOT NULL,
    pocEmail VARCHAR(51) NOT NULL,
    pocPhone VARCHAR(26) NOT NULL,
    pocInstitution VARCHAR(101) NOT NULL
);

-- We need to add a unique identifier for ArtifactID as a foreign key. We will do that during the final project process.
DROP TABLE IF EXISTS Artifacts;
CREATE TABLE Artifacts (
    artifactID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    pocID  INT(11) NOT NULL,
    onSite BOOLEAN NOT NULL DEFAULT TRUE,
    institutionalID VARCHAR(101),
    location VARCHAR(50) NOT NULL,
    ipHolder VARCHAR(50),
    license VARCHAR(50),
    classification VARCHAR(50) NOT NULL,
    cultural BOOLEAN NOT NULL DEFAULT FALSE,
    archaeology BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (pocID) REFERENCES PointsOfContact(pocID)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Technicians;
CREATE TABLE Technicians (
    techID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    techFName VARCHAR(26) NOT NULL,
    techLName VARCHAR(26) NOT NULL,
    techEmail VARCHAR(51) NOT NULL,
    techPhone VARCHAR(26) NOT NULL
);

DROP TABLE IF EXISTS 3DScans;
CREATE TABLE 3DScans (
    scanID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    artifactID INT(11) NOT NULL,
    labPOCID INT(11) NOT NULL,
    techID INT(11) NOT NULL,
    scanDate DATE NOT NULL,
    units VARCHAR(10) NOT NULL DEFAULT 'mm',
    scanMethod VARCHAR(50) NOT NULL,
    derived BOOLEAN NOT NULL DEFAULT FALSE,
    fileName VARCHAR (50) NOT NULL UNIQUE,
    doi VARCHAR (50),
    FOREIGN KEY (artifactID) REFERENCES Artifacts(artifactID) 
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (labPOCID) REFERENCES PointsOfContact(pocID) 
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (techID) REFERENCES Technicians(techID) 
    ON DELETE RESTRICT ON UPDATE CASCADE
);


--Finally, creating the intersection table, though we decided that it would be better for it's own
--incrementing PK rather than relying on the FKs.

DROP TABLE IF EXISTS ScanPOCs;
CREATE TABLE ScanPOCs (
    scanPOCID INT(11) AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
    pocID INT(11) NOT NULL,
    scanID INT(11) NOT NULL,
    FOREIGN KEY (pocID) REFERENCES PointsOfContact(pocID) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (scanID) REFERENCES 3DScans(scanID) 
    ON DELETE CASCADE ON UPDATE CASCADE
);



--INSERT DEFINITIONS--


--There will be multiple points of contact made to stress the M:N relationship between points of contact and 3dscans.
--To show the 1:M relationship between points of contact and artifacts, the entered points of contact will also be linked to up to 2 artifacts.
--The first point of contact will be the technician used for the 
--LabPOCID value or the required relationship between 3dscans and poc.
--The second point of contact will be used for 1 3dscan and 1 artifact.
--The third point of contact will be used for 0 3dscans and 2 artifacts.
INSERT INTO PointsOfContact (
    active,
    pocFName,
    pocLName,
    pocEmail,
    pocPhone,
    pocInstitution
)
VALUES
(
    1,
    'Samwell',
    'Tarly',
    'STarly@housetarly.com',
    '555-432-9876',
    'The Citadel Library'
),
(
    0,
    'Jaime',
    'Lannister',
    'JLannister@houselannister.com',
    '222-543-6789',
    'Kings Landing'
),
(
    1,
    'Cersei',
    'Lannister',
    'CLannister@houselannister.com',
    '222-543-6799',
    'Kings Landing'
);

--This poc will be used for 2 3dscans and no artifacts. no active boolean will be provided here to show the default value
INSERT INTO PointsOfContact (
    pocFName,
    pocLName,
    pocEmail,
    pocPhone,
    pocInstitution
)
VALUES
(
    'Tyrion',
    'Lannister',
    'TLannister@houselannister.com',
    '222-345-6789',
    'All around Westeros'
);



--Inserting enough artifacts to cover the examples of the 1:M relationship it has
--between not only PoC but also with 3dScans.

INSERT INTO Artifacts (
    pocID,
    onSite,
    institutionalID,
    location,
    ipHolder,
    license,
    classification,
    cultural,
    archaeology
)
VALUES
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Jaime' AND pocLName = 'Lannister'),
    1,
    NULL,
    '3D Scanning Lab',
    'Pacific Slope Archaeological Laboratory',
    'CC BY-NC-SA 4.0',
    'Groundstone',
    0,
    0
),
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Cersei' AND pocLName = 'Lannister'),
    1,
    'CS191',
    '3D Scanning Lab',
    'Pacific Slope Archaeological Laboratory',
    'CC BY-NC-SA 4.0',
    'Vertebra',
    0,
    0
),
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Cersei' AND pocLName = 'Lannister'),
    0,
    NULL,
    'N/a',
    'Archaeomodels',
    'CC BY-SA',
    'Bifacial',
    1,
    0
);




-- To show the 1:M relationship between technicians and 3dscans, there will be 3
-- test case technicians, each linked to a different amount of 3dscans.
INSERT INTO Technicians (
    techFName,
    techLName,
    techEmail,
    techPhone
)
VALUES
(
    -- This technician will be attached to 2 3d scans
    'Jon',
    'Snow',
    'JSnow@housestark.com',
    '111-222-3333'
),
(
    -- This technician will be attached to 1 3d scan
    'Arya',
    'Stark',
    'AStark@housestark.com',
    '111-223-3334'
),
(
    -- This technician will exist without a 3dScan, emphasizing that a 3dScan for a technician is optional
    'Sansa',
    'Stark',
    'SStark@housestark.com',
    '111-233-3344'
);


--This was said earlier but will put again here for clarification.
--We recognize that we have not thought of a way to select the ArtifactID as a foreign key besides hard coded numbers.
--We will work on that for the final draft of part 2.
--each 3dscan will demonstrate the different levels of the M:N relationship that 3DScans has with PointsOfContact
INSERT INTO 3DScans (
    artifactID,
    labPOCID,
    techID,
    scanDate,
    scanMethod,
    derived,
    fileName
)
VALUES
(
    (SELECT artifactID FROM Artifacts WHERE artifactID = 1),
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT techID FROM Technicians WHERE techFName = 'Jon' AND techLName = 'Snow'),
    '20260106',
    'Structured Light',
    0,
    'Scan_1_Cobble_No_Text.stl'
),
(
    (SELECT artifactID FROM Artifacts WHERE artifactID = 2),
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT techID FROM Technicians WHERE techFName = 'Jon' AND techLName = 'Snow'),
    '20260113',
    'Structured Light',
    0,
    'vertebra_text.obj'
),
(
    (SELECT artifactID FROM Artifacts WHERE artifactID = 2),
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
    (SELECT techID FROM Technicians WHERE techFName = 'Arya' AND techLName = 'Stark'),
    '20260113',
    'Structured Light',
    0,
    'vertebra_no_text.obj'
);


--Inserting enough test data with the pocID and scanID FKs to showcase the M:N relationship between them.
INSERT INTO ScanPOCs (
    pocID,
    scanID
)
VALUES
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Jaime' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans WHERE fileName = 'Scan_1_Cobble_No_Text.stl')
),
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans WHERE fileName = 'Scan_1_Cobble_No_Text.stl')
),
(
    (SELECT pocID FROM PointsOfContact WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
    (SELECT scanID FROM 3DScans WHERE fileName = 'vertebra_text.obj')
);

SET foreign_key_checks=1;
COMMIT;