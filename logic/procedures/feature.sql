/*                   FEATURE'S PROCEDURES                   */

/*
    NAME: add_new_feature
    DESCRIPTION: Add new item to features tables
*/


CREATE PROCEDURE add_new_feature (IN f_name VARCHAR(50), IN associated_release_id INT, IN f_start_date DATE, IN f_end_date DATE, IN f_duration INT, IN f_description TEXT)
BEGIN
	DECLARE calc_f_end_date DATE;
	DECLARE calc_f_duration INT;
    DECLARE get_f_end_date DATE;

	IF f_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
        IF f_end_date IS NOT NULL AND f_duration IS NOT NULL THEN
			SIGNAL SQLSTATE '45001'
			SET MESSAGE_TEXT = 'Enter either the end_date or the duration, not both';
		END IF; 

		IF f_end_date IS NULL AND f_duration IS NOT NULL THEN
			SET calc_f_end_date = DATE_ADD(f_start_date, INTERVAL f_duration DAY);
		END IF;
		
		IF f_duration IS NULL AND f_end_date IS NOT NULL THEN
			SET calc_f_duration = DATEDIFF(f_end_date, f_start_date);
		END IF;

		INSERT INTO features (name, release_id, start_date, end_date, duration, description)
		VALUES (f_name, associated_release_id, IFNULL(f_start_date, CURDATE()), IFNULL(f_end_date, calc_f_end_date), IFNULL(f_duration, calc_f_duration), IFNULL(f_description, "Description"));
        
        CALL start_date_check_trigger_call_features(associated_release_id, f_start_date);

        SELECT end_date INTO get_f_end_date FROM features where name = f_name;
        CALL end_date_check_trigger_call_features(associated_release_id, get_f_end_date);

	END IF;
END ;

/*
 NAME: delete_feature
 DESCRIPTION: Deletes a row from features table
*/


CREATE PROCEDURE delete_feature (IN selected_id INT)
BEGIN
    DELETE FROM features
    WHERE id = selected_id;
END ;

/*
 NAME: edit_feature_name
 DESCRIPTION: Edits the name column from feature table
*/


CREATE PROCEDURE edit_feature_name (IN new_name VARCHAR(50), IN reference_id INT)
BEGIN
    UPDATE features
    SET name = new_name
    WHERE id = reference_id;
END ;

/*
 NAME: edit_feature_associated_release_id
 DESCRIPTION: Edits the associated_release_id column from feature table
*/


CREATE PROCEDURE edit_feature_associated_release_id (IN new_release_id INT, IN reference_id INT)
BEGIN
    UPDATE features
    SET release_id = new_release_id
    WHERE id = reference_id;
END ;

/*
 NAME: edit_feature_start_date
 DESCRIPTION: Edits the start date column from feature table
*/


CREATE PROCEDURE edit_feature_start_date (IN new_start_date DATE, IN reference_id INT)
BEGIN
    DECLARE associated_release_id INT;
    DECLARE old_start_date DATE;
    DECLARE offset INT;

    SELECT start_date INTO old_start_date FROM features WHERE id = reference_id;
	UPDATE features SET start_date = new_start_date WHERE id = reference_id;

    SELECT start_date INTO new_start_date FROM features WHERE id = reference_id;
    SELECT release_id INTO associated_release_id FROM features WHERE id = reference_id;
    
    IF check_release_start_date(associated_release_id) > new_start_date THEN
		CALL trigger_releases_start_date_update ();
    END IF;
        
    SET offset = calc_offset(new_start_date, old_start_date);
    UPDATE sub_features SET start_date = DATE_ADD(start_date, INTERVAL offset DAY) WHERE feature_id = reference_id;
    
END ;

/*
 NAME: edit_feature_end_date
 DESCRIPTION: Edits the end date column from feature table
*/


CREATE PROCEDURE edit_feature_end_date (IN new_end_date DATE, IN reference_id INT)
BEGIN
    DECLARE existing_start_date DATE;
    DECLARE new_duration INT;

    SELECT start_date INTO existing_start_date FROM features WHERE id = reference_id;

    SET new_duration = DATEDIFF(new_end_date, existing_start_date);

    IF new_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End date cannot be before start date.';
    ELSE
        UPDATE features
        SET 
            end_date = new_end_date,
            duration = new_duration
        WHERE id = reference_id;
    END IF;
END ;

/*
 NAME: edit_feature_duration
 DESCRIPTION: Edits the duration column from feature table
*/


CREATE PROCEDURE edit_feature_duration (IN new_duration INT, IN reference_id INT)
BEGIN

	IF new_duration < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Price cannot be negative.';
	ELSE
		UPDATE features
		SET 
			duration = new_duration,
			end_date = DATE_ADD(start_date, INTERVAL new_duration DAY)
		WHERE id = reference_id;
	END IF;
END ;

/*
 NAME: edit_feature_description
 DESCRIPTION: Edits the description column from feature table
*/


CREATE PROCEDURE edit_feature_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE features
    SET description = new_description
    WHERE id = reference_id;
END ;



CREATE PROCEDURE start_date_check_trigger_call_features(IN associated_release_id INT, IN f_start_date DATE)
BEGIN

    DECLARE associated_project_id INT;

	IF check_release_start_date(associated_release_id) > f_start_date THEN
	    CALL trigger_releases_start_date_update ();

        SELECT project_id INTO associated_project_id FROM releases WHERE id = associated_release_id;
        IF check_project_start_date(associated_project_id) > check_release_start_date(associated_release_id) THEN 
            CALL trigger_projects_start_date_update ();
        END IF;
	END IF;
END ;


CREATE PROCEDURE end_date_check_trigger_call_features(IN associated_release_id INT, IN f_end_date DATE)
BEGIN
    DECLARE associated_project_id INT;

	IF check_release_end_date(associated_release_id) < f_end_date THEN 
		CALL trigger_releases_end_date_update ();
        
        SELECT project_id INTO associated_project_id FROM releases WHERE id = associated_release_id;
        IF check_project_end_date(associated_project_id) < check_release_end_date(associated_release_id) THEN 
            CALL trigger_projects_end_date_update ();

        END IF;
	END IF;
END ;




CREATE PROCEDURE trigger_features_start_date_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_start_date = 1;
	UPDATE trigger_controls SET tc_update_features_start_date = 0;
END ;


CREATE PROCEDURE trigger_features_end_date_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_end_date = 1;
	UPDATE trigger_controls SET tc_update_features_end_date = 0;
END ;

