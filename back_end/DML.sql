-- -----------------------------------------------------------
-- 3D SCANS
-- -----------------------------------------------------------
-- READ 3DScans list
SELECT 3DScans.scanID AS 'ID', 3DScans.scanDate AS 'Scan Date', 3DScans.fileName AS 'File Name', 
    Artifacts.artifactID AS 'Artifact ID', Technicians.techEmail AS 'Technician Contact', 
    PointsOfContact.pocEmail AS 'Lab Contact', 3DScans.units AS 'Units', 3DScans.scanMethod AS 'Scan Method', 
    3DScans.derived FROM 3DScans 
    LEFT JOIN Artifacts ON 3DScans.artifactID = Artifacts.artifactID 
    LEFT JOIN Technicians ON 3DScans.techID = Technicians.techID 
    LEFT JOIN PointsOfContact ON 3DScans.labPOCID = PointsOfContact.pocID;
-- SELECT Technicians information for 3DScans LEFT JOIN
SELECT * FROM Technicians;
-- SELECT PointsOfContact information for 3DScans LEFT JOIN
SELECT * FROM PointsOfContact;
-- SELECT Artifacts information for 3DScans LEFT JOIN
SELECT * FROM Artifacts;

-- -----------------------------------------------------------
-- ARTIFACTS
-- -----------------------------------------------------------
-- READ Artifacts list
SELECT Artifacts.artifactID AS 'ID', Artifacts.pocID AS 'Contact Email', Artifacts.onSite AS 'On Site', 
    Artifacts.institutionalID AS 'Institutional ID', Artifacts.location AS 'Location', 
    Artifacts.ipHolder AS 'IP Holder', Artifacts.license AS 'License', Artifacts.classification AS 'Classification', 
    Artifacts.cultural AS 'Cultural', Artifacts.archaeology AS 'Archaeology' 
    FROM Artifacts 
    LEFT JOIN PointsOfContact ON Artifacts.pocID = PointsOfContact.pocID;
-- SELECT PointsOfContact information for Artifacts LEFT JOIN
SELECT * FROM PointsOfContact;

-- -----------------------------------------------------------
-- TECHNICIANS
-- -----------------------------------------------------------
-- READ Technicians list
SELECT techID AS 'ID', CONCAT(techFName, ' ', techLName) AS 'Technician Name', 
    techEmail AS 'Email', techPhone AS 'Phone Number' FROM Technicians;

-- -----------------------------------------------------------
-- POINTS OF CONTACT
-- -----------------------------------------------------------
-- READ Points of Contact list
SELECT pocID AS 'ID', CONCAT(pocFName, ' ', pocLName) as 'Contact Name', 
    pocEmail AS 'Email', pocPhone AS 'Phone Number', 
    pocInstitution AS 'Institution', active FROM PointsOfContact;

-- -----------------------------------------------------------
-- SCAN POINTS OF CONTACT
-- -----------------------------------------------------------
-- READ the Scan points of contact information
SELECT ScanPOCs.scanPOCID AS 'ID', 3DScans.fileName AS 'Scan File', 
    PointsOfContact.pocEmail AS 'Contact Email' FROM ScanPOCs 
    LEFT JOIN 3DScans ON ScanPOCs.scanID = 3DScans.scanID 
    LEFT JOIN PointsOfContact ON ScanPOCs.pocID = PointsOfContact.pocID;
-- SELECT 3DScans information for ScanPOCs LEFT JOIN
SELECT * FROM 3DScans;
-- SELECT PointsOfContact information for ScanPOCs LEFT JOIN
SELECT * FROM PointsOfContact;

-- INSERT ScanPOCs
-- Associate a 3DScan with a Point of Contact (M-to-M relationship addition)
INSERT INTO ScanPOCs (pocID, scanID) VALUES
(:pocIDInput, :scanIDInput);

-- UPDATE ScanPOCS 
-- READ the ScanPOCIDs, the scan file names, and the POC emails to populate the ScanPOCs dropdown
SELECT scanPOCID, scanID, pocID FROM ScanPOCs;
-- READ the Scan ID and the scan file names to populate the Scan dropdown
SELECT scanID, fileName FROM 3DScans;
-- READ the POC ID, first names, last names and the POC emails to populate the POC dropdown
SELECT pocID, pocFName, pocLName, pocEmail FROM PointsOfContact;
-- UPDATE ScanPOCs data based on submission of the Update a ScanPOCs form
UPDATE ScanPOCs SET scanID = :scanIDInput, pocID= :pocIDInput 
    WHERE ScanPOCID= :scanPOCIDInput;

-- DELETE ScanPOCs
-- Dis-associate a Point of Contact from a 3DScan (M-to-M relationship deletion)
DELETE FROM ScanPOCs 
WHERE pocID = :deletePOCIDInput 
AND scanID = :deleteScanIDInput;





