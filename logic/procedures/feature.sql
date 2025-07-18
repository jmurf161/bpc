/*                   FEATURE'S PROCEDURES                   */

/*
 NAME: add_new_feature
 DESCRIPTION: Add new item to features tables
*/

CREATE PROCEDURE add_new_feature (IN f_name VARCHAR(50), IN associated_release_id INT, IN f_start_date DATE, IN f_duration INT, IN f_description TEXT)
BEGIN
	DECLARE feature_end_date DATE;
	DECLARE release_end_date DATE;

	IF f_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
		INSERT INTO features (name, release_id, start_date, duration, description)
		VALUES (f_name, associated_release_id, IFNULL(f_start_date, CURDATE()), IFNULL(f_duration, 0), IFNULL(f_description, "Description"));
        
        IF check_release_start_date(associated_release_id) > f_start_date THEN
		    CALL trigger_releases_start_date_up_update ();
            
            SET feature_end_date = f_start_date + f_duration;
            IF check_release_end_date(associated_release_id) < feature_end_date THEN 
		        CALL trigger_releases_end_date_up_update ();
	        END IF;
	    END IF;
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

	UPDATE features
    SET start_date = new_start_date WHERE id = reference_id;

    SELECT start_date INTO new_start_date FROM features WHERE id = reference_id;
    SELECT release_id INTO associated_release_id FROM features WHERE id = reference_id;
    

    IF check_release_start_date(associated_release_id) > new_start_date THEN
		CALL trigger_releases_start_date_up_update ();
    END IF;
        
    SET offset = calc_offset(new_start_date, old_start_date);

    UPDATE sub_features 
    SET 
        start_date = DATE_ADD(start_date, INTERVAL offset DAY)
    WHERE feature_id = reference_id;
    
END ;

/*
 NAME: edit_feature_end_date
 DESCRIPTION: Edits the end date column from feature table
*/


CREATE PROCEDURE edit_feature_end_date (IN new_end_date DATE, IN reference_id INT)
BEGIN
    DECLARE existing_start_date DATE;
    DECLARE new_duration INT;

    SELECT start_date INTO existing_start_date
    FROM features
    WHERE id = reference_id;

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








/*
CREATE PROCEDURE start_date_check_trigger_call_features(IN associated_release_id INT, IN f_start_date DATE)
BEGIN

	IF check_release_start_date(associated_release_id) > f_start_date THEN
		CALL trigger_releases_start_date_up_update ();
        
	END IF;
END ;


CREATE PROCEDURE end_date_check_trigger_call_features(IN associated_release_id INT, IN feature_end_date DATE)
BEGIN

	IF check_release_end_date(associated_release_id) < feature_end_date THEN 
		CALL trigger_releases_end_date_up_update ();
        
	END IF;
END ;
*/











CREATE PROCEDURE trigger_features_start_date_up_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_start_date_up = 1;
	UPDATE trigger_controls SET tc_update_features_start_date_up = 0;
END ;


CREATE PROCEDURE trigger_features_end_date_up_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_end_date_up = 1;
	UPDATE trigger_controls SET tc_update_features_end_date_up = 0;
END ;


CREATE PROCEDURE trigger_features_start_date_down_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_start_date_down = 1;
	UPDATE trigger_controls SET tc_update_features_start_date_down = 0;
END ;


CREATE PROCEDURE trigger_features_end_date_down_update()
BEGIN
	UPDATE trigger_controls SET tc_update_features_end_date_down = 1;
	UPDATE trigger_controls SET tc_update_features_end_date_down = 0;
END ;
