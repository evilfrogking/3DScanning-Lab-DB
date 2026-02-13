-- get the 3DScans information
SELECT 3DScans.scanID, 3DScans.scanDate, 3DScans.fileName, 
    Artifacts.artifactID AS 'artifactID', Technicians.techEmail AS 'techID', 
    PointsOfContact.pocEmail AS 'labPOCID', 3DScans.units, 3DScans.scanMethod, 
    3DScans.derived FROM 3DScans 
    LEFT JOIN Artifacts ON 3DScans.artifactID = Artifacts.artifactID 
    LEFT JOIN Technicians ON 3DScans.techID = Technicians.techID 
    LEFT JOIN PointsOfContact ON 3DScans.labPOCID = PointsOfContact.pocID;

-- get the Point of contact information
SELECT pocID, pocFName, pocLName, pocEmail, pocPhone, 
        pocInstitution, active FROM PointsOfContact;

-- get all Artifact information
SELECT Artifacts.artifactID, Artifacts.pocID, Artifacts.onSite, 
    Artifacts.institutionalID, Artifacts.location, 
    Artifacts.ipHolder, Artifacts.license, Artifacts.classification, 
    Artifacts.cultural, Artifacts.archaeology 
    FROM Artifacts 
    LEFT JOIN PointsOfContact ON Artifacts.pocID = PointsOfContact.pocID;
-- get PointsOfContact information for Artifacts
SELECT * FROM PointsOfContact;

-- get all Technician information
SELECT Technicians.techID, Technicians.techFName, Technicians.techLName, 
    Technicians.techEmail, Technicians.techPhone 
    FROM Technicians;

-- get all the Scan points of contact information
SELECT ScanPOCs.scanPOCID, 3DScans.fileName AS 'scanID', 
    PointsOfContact.pocEmail AS 'pocID' FROM ScanPOCs 
    LEFT JOIN 3DScans ON ScanPOCs.scanID = 3DScans.scanID 
    LEFT JOIN PointsOfContact ON ScanPOCs.pocID = PointsOfContact.pocID;

-- get the ScanPOCIDs, the scan file names, and the POC emails to populate the ScanPOC dropdown
SELECT ScanPOC.scanPOCID, ScanPOC.scanID, ScanPOC.pocID FROM ScanPOC;

-- get the Scan ID and the scan file names to populate the Scan dropdown
SELECT 3DScans.scanID, 3DScans.filename FROM 3DScans;

-- get the POC ID, first names, last names and the POC emails to populate the POC dropdown
SELECT PointsOfContact.pocID, PointsOfContact.pocFName, PointsOfContact.pocLName, PointsOfContact.pocEmail FROM PointsOfContact;

-- update ScanPOCs data based on submission of the Update a ScanPOC form
UPDATE ScanPOCs SET ScanPOC.scanID = :scanIDInput, ScanPOC.pocID= :pocIDInput
    WHERE ScanPOCID= :scanPOCIDInput


