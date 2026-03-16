/* 
   File: plsql.sql
   Purpose: Contains all of our Stored Procedures, including the one to restart the database and insert test data, and the one to delete a scanPOC.
     - sp_RestartDatabase: drops all tables if they exist, creates all tables, and inserts test data.
     - sp_delete_scanPOC: deletes a scanPOC by its PK, with error handling to prevent deletion if the scanPOC is still in use by a 3DScan.
     - sp_create_scanPOC: creates a scanPOC by its PK, with error handling to prevent creation if the scanPOC is already in use by a 3DScan.
   Author: Aspen Frazee and Alexander Hinson
   Created: 02-12-2026
   Last Update: 03-13-2026
*/

-- ================
-- DROP DEFINITIONS
-- ================
DROP PROCEDURE IF EXISTS sp_RestartDatabase;
DROP PROCEDURE IF EXISTS sp_delete_scanPOC;
DROP PROCEDURE IF EXISTS sp_create_scanPOC;
DROP PROCEDURE IF EXISTS sp_update_scanPOC;

DELIMITER //

/* 
   Procedure: sp_RestartDatabase
   Author: Alexander Hinson. Edited by Aspen Frazee.
   Created: 02-12-2026
   Behavior:
     - Drops all tables if they exist, creates all tables, and inserts test data.
*/
CREATE PROCEDURE `sp_RestartDatabase`()
BEGIN
    SET foreign_key_checks=0;

    /* 
    CITATION:
        Date: 2/12/2026
        Prompts used to generate SQL
        Find the purpose for the error message:
        1451 - Cannot delete or update a parent row: a foreign key constraint fails
        AI Source URL: https://https://chatgpt.com/
    */
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
        artifactID INT(11) NOT NULL,
        labPOCID INT(11) NOT NULL,
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
    START TRANSACTION; -- Copilot recommendation: "Put DML in a transaction; DDL has already committed"
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
        NULL,
        '3D Scanning Lab',
        'Pacific Slope Archaeological Laboratory',
        'CC BY-NC-SA 4.0',
        'Groundstone',
        0, 0
    ),
    (
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Cersei' AND pocLName = 'Lannister'),
        1,
        'CS191',
        '3D Scanning Lab',
        'Pacific Slope Archaeological Laboratory',
        'CC BY-NC-SA 4.0',
        'Vertebra',
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
        'Bifacial',
        1, 0
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
        '111-223-3334'
    ),
    (
        'Sansa', 'Stark',
        'SStark@housestark.com',
        '111-233-3344'
    );

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
        (SELECT artifactID FROM Artifacts 
            WHERE artifactID = 1),
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
        (SELECT techID FROM Technicians 
            WHERE techFName = 'Jon' AND techLName = 'Snow'),
        '20260106',
        'Structured Light',
        0,
        'Scan_1_Cobble_No_Text.stl'
    ),
    (
        (SELECT artifactID FROM Artifacts 
            WHERE artifactID = 2),
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
        (SELECT techID FROM Technicians 
            WHERE techFName = 'Jon' AND techLName = 'Snow'),
        '20260113',
        'Structured Light',
        0,
        'vertebra_text.obj'
    ),
    (
        (SELECT artifactID FROM Artifacts 
            WHERE artifactID = 2),
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Samwell' AND pocLName = 'Tarly'),
        (SELECT techID FROM Technicians 
            WHERE techFName = 'Arya' AND techLName = 'Stark'),
        '20260113',
        'Structured Light',
        0,
        'vertebra_no_text.obj'
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
        WHERE fileName = 'Scan_1_Cobble_No_Text.stl')
    ),
    (
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
        (SELECT scanID FROM 3DScans 
            WHERE fileName = 'Scan_1_Cobble_No_Text.stl')
    ),
    (
        (SELECT pocID FROM PointsOfContact 
            WHERE pocFName = 'Tyrion' AND pocLName = 'Lannister'),
        (SELECT scanID FROM 3DScans 
            WHERE fileName = 'vertebra_text.obj')
    );

    COMMIT;
END //
-- end sp_RestartDatabase

/* 
   Procedure: sp_delete_scanPOC
   Author: Aspen Frazee. Edited by Alexander Hinson.
   Created: 03-02-2026
   Behavior:
        Deletes a scanPOC by its PK, with error handling to prevent deletion
        if the scanPOC is still in use by a 3DScan.
    CITATION for AI use:
        Date: 2/12/2026
        Prompts used:
            Write a stored procedure for MariaDB called sp_delete_scanPOC 
            that deletes a scan point of contact (POC) from the ScanPOCs table 
            based on the provided scanPOCID. 
            The procedure should return a message indicating 
            whether the deletion was successful or if there was an error 
            (e.g., if the scanPOCID does not exist 
            or if there are foreign key constraints preventing the deletion). 
            Use appropriate error handling to manage exceptions 
            and ensure that the database remains consistent.
        AI Source URL: https://m365.cloud.microsoft/chat/
*/
CREATE PROCEDURE `sp_delete_scanPOC`(IN `p_scanPOCID` INT)
BEGIN
    DECLARE v_msg VARCHAR(64);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN
        ROLLBACK;
        SELECT 'Error! Scan''dout still in!' AS v_msg;
    END;

    START TRANSACTION;
    DELETE FROM `ScanPOCs`
    WHERE `scanPOCID` = p_scanPOCID;

    IF ROW_COUNT() = 1 THEN
        COMMIT;
        SELECT 'Scan''dout out' AS v_msg;
    ELSE
        ROLLBACK;
        SELECT 'Error! Scan''dout still in!' AS v_msg;
    END IF;
END //
-- end sp_delete_scanPOC

/* 
   Procedure: sp_create_scanPOC
   Author: Alexander Hinson. Edited by Aspen Frazee.
   Created: 03-09-2026
   Behavior:
        Creates a scanPOC by its PK, with error handling to prevent creation
        if the scanPOC is already in use by a 3DScan.
    CITATION:
        Date: 3/9/2026
        Source: This functionality is from a template that was provided in the
            "Implementing CUD operations in your app" exploration.
*/
CREATE PROCEDURE sp_create_scanPOC(
    IN s_id INT, 
    IN c_id INT, 
    OUT scanPOC_id INT)
BEGIN
    INSERT INTO ScanPOCs (pocID, scanID) 
    VALUES (c_id, s_id);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into scanPOC_id;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

END //
-- end sp_create_scanPOC

/* 
   Procedure: sp_update_scanPOC
   Author: Aspen Frazee
   Created: 03-09-2026
   Behavior:
        Updates a scanPOC by its PK, with error handling to prevent updates
        if the scanPOC is already in use by a 3DScan.
    Note:
        I had used Copilot origionally to make the update functionality,
        but after encountering an error, I rewrote the code.
*/
CREATE PROCEDURE sp_update_scanPOC(
    IN p_scanPOCID INT,
    IN p_pocID INT)
BEGIN
    UPDATE ScanPOCs 
    SET 
        pocID = p_pocID 
    WHERE scanPOCID = p_scanPOCID;
END //
-- end sp_update_scanPOC

DELIMITER ;
