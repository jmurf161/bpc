/*                   release'S PROCEDURES                   */

/*
 NAME: add_new_release
 DESCRIPTION: Add new item to releases tables
*/

CREATE PROCEDURE add_new_release (IN r_name VARCHAR(50), IN associated_project_id INT, IN r_start_date DATE, IN r_duration INT, IN r_description TEXT)
BEGIN
	DECLARE release_end_date DATE;

	IF r_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
		INSERT INTO releases (name, project_id, start_date, duration, description)
		VALUES (r_name, associated_project_id, IFNULL(r_start_date, CURDATE()), IFNULL(r_duration, 0), IFNULL(r_description, "Description"));
        
        CALL start_date_check_trigger_call_releases(associated_project_id, r_start_date);
        
        SET release_end_date = DATE_ADD(r_start_date, INTERVAL r_duration DAY);
        UPDATE releases SET end_date = release_end_date WHERE end_date IS NULL;

        CALL end_date_check_trigger_call_releases(associated_project_id, release_end_date);

	END IF;
END ;

/*
 NAME: delete_release
 DESCRIPTION: Deletes a row from releases table
*/


CREATE PROCEDURE delete_release (IN selected_id INT)
BEGIN
    DELETE FROM releases
    WHERE id = selected_id;
END ;

/*
 NAME: edit_release_name
 DESCRIPTION: Edits the name column from release table
*/


CREATE PROCEDURE edit_release_name (IN new_name VARCHAR(50), IN reference_id INT)
BEGIN
    UPDATE releases
    SET name = new_name
    WHERE id = reference_id;
END ;

/*
 NAME: edit_release_associated_project_id
 DESCRIPTION: Edits the associated_project_id column from release table
*/


CREATE PROCEDURE edit_release_associated_project_id (IN new_project_id INT, IN reference_id INT)
BEGIN
    UPDATE releases
    SET project_id = new_project_id
    WHERE id = reference_id;
END ;

/*
 NAME: edit_release_start_date
 DESCRIPTION: Edits the start date column from release table
*/


CREATE PROCEDURE edit_release_start_date (IN new_start_date DATE, IN reference_id INT)
BEGIN   
	
	DECLARE old_start_date DATE;
    DECLARE offset INT;
	
	SELECT start_date INTO old_start_date FROM releases WHERE id = reference_id;
    UPDATE releases r SET start_date = new_start_date WHERE id = reference_id;
	
    SELECT start_date INTO new_start_date FROM releases WHERE id = reference_id;
    SET offset = calc_offset(new_start_date, old_start_date);
    
	UPDATE features 
	SET 
		start_date = DATE_ADD(start_date, INTERVAL offset DAY)
	WHERE release_id = reference_id;

	UPDATE sub_features sf
	JOIN features f ON sf.feature_id = f.id
	SET sf.start_date = DATE_ADD(sf.start_date, INTERVAL offset DAY)
	WHERE f.release_id = reference_id;

END ;

/*
 NAME: edit_release_end_date
 DESCRIPTION: Edits the end date column from release table
*/


CREATE PROCEDURE edit_release_end_date (IN new_end_date DATE, IN reference_id INT)
BEGIN
    DECLARE existing_start_date DATE;
    DECLARE new_duration INT;

    SELECT start_date INTO existing_start_date FROM releases WHERE id = reference_id;
    SET new_duration = DATEDIFF(new_end_date, existing_start_date);

    IF new_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End date cannot be before start date.';
    ELSE
        UPDATE releases
        SET 
            end_date = new_end_date,
            duration = new_duration
        WHERE id = reference_id;
    END IF;
END ;

/*
 NAME: edit_release_duration
 DESCRIPTION: Edits the duration column from release table
*/


CREATE PROCEDURE edit_release_duration (IN new_duration INT, IN reference_id INT)
BEGIN

	IF new_duration < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Price cannot be negative.';
	ELSE
		UPDATE releases
		SET 
			duration = new_duration,
			end_date = DATE_ADD(start_date, INTERVAL new_duration DAY)
		WHERE id = reference_id;
	END IF;
END ;

/*
 NAME: edit_release_description
 DESCRIPTION: Edits the description column from release table
*/


CREATE PROCEDURE edit_release_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE releases
    SET description = new_description
    WHERE id = reference_id;
END ;









CREATE PROCEDURE start_date_check_trigger_call_releases(IN associated_project_id INT, IN r_start_date DATE)
BEGIN

	IF check_project_start_date(associated_project_id) > r_start_date THEN
	    CALL trigger_projects_start_date_update ();

	END IF;
END ;


CREATE PROCEDURE end_date_check_trigger_call_releases(IN associated_project_id INT, IN r_end_date DATE)
BEGIN

	IF check_project_end_date(associated_project_id) < r_end_date THEN 
		CALL trigger_projects_end_date_update ();
    
	END IF;
END ;




CREATE PROCEDURE trigger_releases_start_date_update()
BEGIN
	UPDATE trigger_controls SET tc_update_releases_start_date = 1;
	UPDATE trigger_controls SET tc_update_releases_start_date = 0;
END ;


CREATE PROCEDURE trigger_releases_end_date_update()
BEGIN
	UPDATE trigger_controls SET tc_update_releases_end_date = 1;
	UPDATE trigger_controls SET tc_update_releases_end_date = 0;
END ;