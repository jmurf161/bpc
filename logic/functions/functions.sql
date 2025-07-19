/*                   FUNCTIONS                   */




CREATE FUNCTION check_subf_start_date(associated_subf_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT start_date INTO result
    FROM sub_features
    WHERE id = associated_subf_id;

    RETURN result;
END ;



CREATE FUNCTION check_subf_end_date(associated_subf_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT end_date INTO result
    FROM sub_features
    WHERE id = associated_subf_id;

    RETURN result;
END ;





CREATE FUNCTION check_feature_start_date(associated_feature_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT start_date INTO result
    FROM features
    WHERE id = associated_feature_id;

    RETURN result;
END ;



CREATE FUNCTION check_feature_end_date(associated_feature_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT end_date INTO result
    FROM features
    WHERE id = associated_feature_id;

    RETURN result;
END ;


CREATE FUNCTION check_release_start_date(associated_release_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT start_date INTO result
    FROM releases
    WHERE id = associated_release_id;

    RETURN result;
END ;


CREATE FUNCTION check_release_end_date(associated_release_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT end_date INTO result
    FROM releases
    WHERE id = associated_release_id;

    RETURN result;
END ;




CREATE FUNCTION check_project_start_date(associated_project_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT start_date INTO result
    FROM projects
    WHERE id = associated_project_id;

    RETURN result;
END ;


CREATE FUNCTION check_project_end_date(associated_project_id INT)
RETURNS DATE
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DATE;

    SELECT end_date INTO result
    FROM projects
    WHERE id = associated_project_id;

    RETURN result;
END ;





CREATE FUNCTION calc_offset(new_start_date DATE, old_start_date DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN 
    DECLARE offset_days INT;

    SET offset_days = DATEDIFF(new_start_date, old_start_date);

    RETURN offset_days;
END ;
