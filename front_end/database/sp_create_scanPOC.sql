-- #############################
-- CREATE ScanPOC
-- #############################

-- This functionality is from a template that was provided in the
-- "Implementing CUD operations in your app" exploration.
DROP PROCEDURE IF EXISTS sp_create_scanPOC;

DELIMITER //
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
DELIMITER ;