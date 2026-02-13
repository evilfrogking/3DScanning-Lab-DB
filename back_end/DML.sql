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

-- get all Technician information
SELECT Technicians.techID, Technicians.techFName, Technicians.techLName, 
    Technicians.techEmail, Technicians.techPhone 
    FROM Technicians;

-- get all the Scan points of contact information
SELECT ScanPOCs.scanPOCID, 3DScans.fileName AS 'scanID', 
    PointsOfContact.pocEmail AS 'pocID' FROM ScanPOCs 
    LEFT JOIN 3DScans ON ScanPOCs.scanID = 3DScans.scanID 
    LEFT JOIN PointsOfContact ON ScanPOCs.pocID = PointsOfContact.pocID;