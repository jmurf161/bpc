/*                   project'S PROCEDURES                   */

/*
 NAME: add_new_project
 DESCRIPTION: Add new item to projects tables


 SET calc_p_end_date = DATE_ADD(p_start_date, INTERVAL p_duration DAY);
 UPDATE projects SET end_date = calc_p_end_date WHERE end_date IS NULL;
*/


CREATE PROCEDURE add_new_project (IN p_name VARCHAR(50), IN p_start_date DATE, IN p_end_date DATE, IN p_duration INT, IN p_description TEXT)
BEGIN

	DECLARE calc_p_end_date DATE;
	DECLARE calc_p_duration INT;

	IF p_duration < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
		IF p_end_date IS NOT NULL AND p_duration IS NOT NULL THEN
			SIGNAL SQLSTATE '45001'
			SET MESSAGE_TEXT = 'Enter either the end_date or the duration, not both';
		END IF; 

		IF p_end_date IS NULL AND p_duration IS NOT NULL THEN
			SET calc_p_end_date = DATE_ADD(p_start_date, INTERVAL p_duration DAY);
		END IF;
		
		IF p_duration IS NULL AND p_end_date IS NOT NULL THEN
			SET calc_p_duration = DATEDIFF(p_end_date, p_start_date);
		END IF;

		INSERT INTO projects (name, start_date, end_date, duration, description)
		VALUES (p_name, IFNULL(p_start_date, CURDATE()), IFNULL(p_end_date, calc_p_end_date), IFNULL(p_duration, calc_p_duration), IFNULL(p_description, "Description"));
		
    END IF;
END ;

/*
 NAME: delete_project
 DESCRIPTION: Deletes a row from projects table
*/


CREATE PROCEDURE delete_project (IN selected_id INT)
BEGIN
    DELETE FROM projects
    WHERE id = selected_id;
END ;

/*
 NAME: edit_project_name
 DESCRIPTION: Edits the name column from projects table
*/


CREATE PROCEDURE edit_project_name (IN new_project_name VARCHAR(50), IN reference_id INT)
BEGIN
    UPDATE projects
    SET name = new_project_name
    WHERE id = reference_id;
END ;

/*
 NAME: edit_project_start_date
 DESCRIPTION: Edits the start date column from projects table
*/

CREATE PROCEDURE edit_project_start_date (IN new_start_date DATE, IN reference_id INT)
BEGIN   
	DECLARE old_start_date DATE;
	DECLARE offset INT;

	SELECT start_date INTO old_start_date FROM projects WHERE id = reference_id;
	UPDATE projects SET start_date = new_start_date WHERE id = reference_id;

	SELECT start_date INTO new_start_date FROM projects WHERE id = reference_id;
	SET offset = calc_offset(new_start_date, old_start_date);

	UPDATE releases SET start_date = DATE_ADD(start_date, INTERVAL offset DAY) WHERE project_id = reference_id;

	UPDATE features f
	JOIN releases r ON f.release_id = r.id
	SET f.start_date = DATE_ADD(f.start_date, INTERVAL offset DAY)
	WHERE r.project_id = reference_id;

	UPDATE sub_features sf
	JOIN features f ON sf.feature_id = f.id
	JOIN releases r ON f.release_id = r.id
	SET sf.start_date = DATE_ADD(sf.start_date, INTERVAL offset DAY)
	WHERE r.project_id = reference_id;

END ;




/*
 NAME: edit_calc_p_end_date
 DESCRIPTION: Edits the end date column from projects table
*/


CREATE PROCEDURE edit_calc_p_end_date (IN new_end_date DATE, IN reference_id INT)
BEGIN

	UPDATE projects
	SET 
		end_date = new_end_date,
		duration = DATEDIFF(new_end_date, start_date)
	WHERE id = reference_id;
END ;

/*
 NAME: edit_calc_p_duration
 DESCRIPTION: Edits the duration column from projects table
*/


CREATE PROCEDURE edit_calc_p_duration (IN new_duration INT, IN reference_id INT)
BEGIN
	IF new_duration < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
		UPDATE projects
		SET 
			duration = new_duration,
			end_date = DATE_ADD(start_date, INTERVAL new_duration DAY)
		WHERE id = reference_id;
	END IF;
END ;

/*
 NAME: edit_project_description
 DESCRIPTION: Edits the description column from sub features table
*/


CREATE PROCEDURE edit_project_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE projects
    SET description = new_description
    WHERE id = reference_id;
END ;










CREATE PROCEDURE trigger_projects_start_date_update()
BEGIN
	UPDATE trigger_controls SET tc_update_projects_start_date = 1;
	UPDATE trigger_controls SET tc_update_projects_start_date = 0;
END ;


CREATE PROCEDURE trigger_projects_end_date_update()
BEGIN        
	UPDATE trigger_controls SET tc_update_projects_end_date = 1;
	UPDATE trigger_controls SET tc_update_projects_end_date = 0;
END ;
