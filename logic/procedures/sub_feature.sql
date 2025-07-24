/*                   SUB_FEATURE'S PROCEDURES                   */

/*
    NAME: add_new_sub_feature
    DESCRIPTION: Add new item to sub_features tables
*/


CREATE PROCEDURE add_new_sub_feature (IN subf_name VARCHAR(50), IN associated_feature_id INT, IN subf_start_date DATE, IN subf_end_date DATE, IN subf_duration INT, IN subf_description TEXT)
BEGIN
	DECLARE calc_subf_end_date DATE;
    DECLARE calc_subf_duration INT;
    DECLARE get_subf_end_date DATE;


    IF subf_end_date IS NOT NULL AND subf_duration IS NOT NULL THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'Enter either the end_date or the duration, not both';

	ELSEIF subf_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duration cannot be negative.';

	ELSE

		IF subf_end_date IS NULL AND subf_duration IS NOT NULL THEN
			SET calc_subf_end_date = DATE_ADD(subf_start_date, INTERVAL subf_duration DAY);
		END IF;
		
		IF subf_duration IS NULL AND subf_end_date IS NOT NULL THEN
			SET calc_subf_duration = DATEDIFF(subf_end_date, subf_start_date);
		END IF;

		INSERT INTO sub_features (name, feature_id, start_date, end_date, duration, description)
		VALUES (subf_name, associated_feature_id, IFNULL(subf_start_date, CURDATE()), IFNULL(subf_end_date, calc_subf_end_date), IFNULL(subf_duration, calc_subf_duration), IFNULL(subf_description, "Description"));
		
        CALL start_date_check_trigger_call_subfs(associated_feature_id, subf_start_date);
        
        SELECT end_date INTO get_subf_end_date FROM sub_features WHERE name = subf_name;
        CALL end_date_check_trigger_call_subfs(associated_feature_id, get_subf_end_date);
       
	END IF;
END ;




/*
  NAME: delete_sub_feature
  DESCRIPTION: Deletes a row from sub_features table
*/

CREATE PROCEDURE delete_sub_feature (IN selected_id INT)
BEGIN
    DELETE FROM sub_features
    WHERE id = selected_id;
END ;


/*
    NAME: edit_sub_feature_name
    DESCRIPTION: Edits the name column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_name (IN new_name VARCHAR(50), IN reference_id INT)
BEGIN
    UPDATE sub_features
    SET name = new_name
    WHERE id = reference_id;
END ;

/*
    NAME: edit_sub_feature_associated_feature_id
    DESCRIPTION: Edits the associated feature id column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_associated_feature_id (IN new_feature_id INT, IN reference_id INT)
BEGIN
    UPDATE sub_features
    SET feature_id = new_feature_id
    WHERE id = reference_id;
END ;

/*
    NAME: edit_sub_feature_start_date
    DESCRIPTION: Edits the start date column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_start_date (IN new_start_date DATE, IN reference_id INT)
BEGIN
	DECLARE assoicated_feature_id INT;

	UPDATE sub_features
    SET 
		start_date = new_start_date,
		end_date = DATE_ADD(new_start_date, INTERVAL duration DAY)
    WHERE id = reference_id;
    
    SELECT feature_id INTO assoicated_feature_id FROM sub_features WHERE id = reference_id;
    CALL start_date_check_trigger_call_subfs(assoicated_feature_id, new_start_date);
END ;

/*
  NAME: edit_sub_feature_end_date
  DESCRIPTION: Edits the start date column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_end_date (IN new_end_date DATE, IN reference_id INT)
BEGIN
    DECLARE existing_start_date DATE;
    DECLARE new_duration INT;

    SELECT start_date INTO existing_start_date
    FROM sub_features
    WHERE id = reference_id;

    SET new_duration = DATEDIFF(new_end_date, existing_start_date);

    IF new_duration < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End date cannot be before start date.';
    ELSE
        UPDATE sub_features
        SET 
            end_date = new_end_date,
            duration = new_duration
        WHERE id = reference_id;
        
        CALL trigger_features_end_date_update ();
        
    END IF;
END ;

/*
  NAME: edit_sub_feature_duration
  DESCRIPTION: Edits the duration column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_duration (IN new_duration INT, IN reference_id INT)
BEGIN
IF new_duration < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Price cannot be negative.';
	ELSE
		UPDATE sub_features
		SET 
			duration = new_duration,
			end_date = DATE_ADD(start_date, INTERVAL new_duration DAY)
		WHERE id = reference_id;
	END IF;
END ;

/*
  NAME: edit_sub_feature_description
  DESCRIPTION: Edits the description column from sub features table
*/


CREATE PROCEDURE edit_sub_feature_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE sub_features
    SET description = new_description
    WHERE id = reference_id;
END ;




CREATE PROCEDURE start_date_check_trigger_call_subfs(IN associated_feature_id INT, IN subf_start_date DATE)
BEGIN
    DECLARE associated_release_id INT;
    DECLARE associated_project_id INT;

	IF check_feature_start_date(associated_feature_id) > subf_start_date THEN 
		CALL trigger_features_start_date_update ();
		
		SELECT release_id INTO associated_release_id FROM features WHERE id = associated_feature_id;
		IF check_release_start_date(associated_release_id) > check_feature_start_date(associated_feature_id) THEN 
			CALL trigger_releases_start_date_update ();
		
            SELECT project_id INTO associated_project_id FROM releases WHERE id = associated_release_id;
            IF check_project_start_date(associated_project_id) > check_release_start_date(associated_release_id) THEN 
                CALL trigger_projects_start_date_update ();
		    
            END IF;
        END IF;
	END IF;	
END ;



CREATE PROCEDURE end_date_check_trigger_call_subfs(IN associated_feature_id INT, IN subf_end_date DATE)
BEGIN
    DECLARE associated_release_id INT;
    DECLARE associated_project_id INT;
    
	IF check_feature_end_date(associated_feature_id) < subf_end_date THEN 
		CALL trigger_features_end_date_update ();
        
		SELECT release_id INTO associated_release_id FROM features WHERE id = associated_feature_id;
		IF check_release_end_date(associated_release_id) < check_feature_end_date(associated_feature_id) THEN 
			CALL trigger_releases_end_date_update ();
			
            
            SELECT project_id INTO associated_project_id FROM releases WHERE id = associated_release_id;
            IF check_project_end_date(associated_project_id) < check_release_end_date(associated_release_id) THEN 
                CALL trigger_projects_end_date_update ();

            END IF;
        END IF;
	END IF;
END ;