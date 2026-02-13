
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
