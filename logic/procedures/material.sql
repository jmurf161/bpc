/*                   MATERIAL'S PROCEDURES                   */

/*
# NAME: add_new_material
# DESCRIPTION: Add new item to materials tables
*/


CREATE PROCEDURE add_new_material (IN mat_name VARCHAR(50), IN mat_price decimal(11,2), IN mat_capex_or_opex BOOLEAN, IN mat_internal_or_external BOOLEAN, IN mat_description TEXT)
BEGIN
	IF mat_price < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Price cannot be negative.';
	ELSE
		INSERT INTO materials (name, price, capex_or_opex, internal_or_external, description)
		VALUES (mat_name, IFNULL(mat_price, 0), IFNULL(mat_capex_or_opex, NULL), IFNULL(mat_internal_or_external, NULL), IFNULL(mat_description, "Description"));
	END IF;
END ;


/*
# NAME: delete_material
# DESCRIPTION: Deletes a row from materials table
*/


CREATE PROCEDURE delete_material (IN selected_id INT)
BEGIN
    DELETE FROM materials
    WHERE id = selected_id;
END ;


/*
# NAME: edit_material_name
# DESCRIPTION: Edits the name column from materials table
*/


CREATE PROCEDURE edit_material_name (IN new_name VARCHAR(50), IN reference_id INT)
BEGIN
    UPDATE materials
    SET name = new_name
    WHERE id = reference_id;
END ;

/*
# NAME: edit_material_price
# DESCRIPTION: Edits the price column from materials table
*/


CREATE PROCEDURE edit_material_price (IN new_price VARCHAR(50), IN reference_id INT)
BEGIN
	IF new_duration < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Price cannot be negative.';
	ELSE
		UPDATE materials
		SET price = new_price
		WHERE id = reference_id;
        END IF;
END ;

/*
# NAME: edit_material_capex_or_opex
# DESCRIPTION: Edits the capex or opex column from materials table
*/


CREATE PROCEDURE edit_material_capex_or_opex (IN true_or_false BOOLEAN, IN reference_id INT)
BEGIN
    UPDATE materials
    SET capex_or_opex = true_or_false
    WHERE id = reference_id;
END ;

/*
# NAME: edit_material_internal_or_external
# DESCRIPTION: Edits the internal or external column from materials table
*/


CREATE PROCEDURE edit_material_internal_or_external (IN true_or_false BOOLEAN, IN reference_id INT)
BEGIN
    UPDATE materials
    SET internal_or_external = true_or_false
    WHERE id = reference_id;
END ;

/*
# NAME: edit_material_description
# DESCRIPTION: Edits the description column from materials table
*/


CREATE PROCEDURE edit_material_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE materials
    SET description = new_description
    WHERE id = reference_id;
END ;