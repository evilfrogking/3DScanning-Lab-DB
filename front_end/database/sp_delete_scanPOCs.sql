
-- CITATION:
-- Date: 2/12/2026
-- Prompts used:
-- Write a stored procedure for MariaDB called sp_delete_scanPOC that deletes a scan point of contact (POC) from the ScanPOCs table based on the provided scanPOCID. The procedure should return a message indicating whether the deletion was successful or if there was an error (e.g., if the scanPOCID does not exist or if there are foreign key constraints preventing the deletion). Use appropriate error handling to manage exceptions and ensure that the database remains consistent.
--  # AI Source URL: https://m365.cloud.microsoft/chat/
DELIMITER //
DROP PROCEDURE sp_delete_scanPOC;
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
DELIMITER ;
