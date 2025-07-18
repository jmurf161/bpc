/*                   ORDER'S PROCEDURES                   */

/*
# NAME: add_new_order
# DESCRIPTION: Add new item to orders tables
*/


CREATE PROCEDURE add_new_order (IN associated_department_id INT, IN associated_material_id INT, IN quantity INT, IN date_ordered_by DATE, IN date_needed_by DATE, IN order_description TEXT)
BEGIN
	INSERT INTO orders (department_id, material_id, quantity, date_ordered_by, date_needed_by, description)
    VALUES (associated_department_id, associated_material_id, IFNULL(quantity, 0), IFNULL(date_ordered_by, CURDATE()), IFNULL(date_needed_by, DATE_ADD(CURDATE(), INTERVAL 15 DAY)), IFNULL(order_description, "Description"));
END ;


/*
# NAME: delete_order
# DESCRIPTION: Deletes a row from orders table
*/


CREATE PROCEDURE delete_order (IN selected_id INT)
BEGIN
    DELETE FROM orders
    WHERE id = selected_id;
END ;


/*
# NAME: edit_order_po_number
# DESCRIPTION: Edits the po_number id column from orders table
*/


CREATE PROCEDURE edit_order_po_number (IN new_po_number INT, IN reference_id INT)
BEGIN
    UPDATE orders
    SET po_number = new_po_number
    WHERE id = reference_id;
END ;

/*
# NAME: edit_order_department_id
# DESCRIPTION: Edits the department id column from orders table
*/


CREATE PROCEDURE edit_order_department_id (IN associated_department_id INT, IN reference_id INT)
BEGIN
    UPDATE orders
    SET department_id = associated_department_id
    WHERE id = reference_id;
END ;

/*
# NAME: edit_order_material_id
# DESCRIPTION: Edits the material id column from orders table
*/


CREATE PROCEDURE edit_order_material_id (IN associated_material_id INT, IN reference_id INT)
BEGIN
    UPDATE orders
    SET material_id = associated_material_id
    WHERE id = reference_id;
END ;

/*
# NAME: edit_order_quantity
# DESCRIPTION: Edits the quantity id column from orders table
*/


CREATE PROCEDURE edit_order_quantity (IN new_quantity INT, IN reference_id INT)
BEGIN
	IF new_duration < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Duration cannot be negative.';
	ELSE
		UPDATE orders
		SET quantity = new_quantity
		WHERE id = reference_id;
	END IF;
END ;

/*
# NAME: edit_order_date_ordered_by
# DESCRIPTION: Edits the date ordered by id column from orders table
*/


CREATE PROCEDURE edit_order_date_ordered_by (IN ordered_date DATE, IN reference_id INT)
BEGIN
    UPDATE orders
    SET date_ordered_by = ordered_date
    WHERE id = reference_id;
END ;

/*
# NAME: edit_order_date_needed_by
# DESCRIPTION: Edits the date needed by id column from orders table
*/


CREATE PROCEDURE edit_order_date_needed_by (IN needed_date DATE, IN reference_id INT)
BEGIN
    UPDATE orders
    SET date_needed_by = needed_date
    WHERE id = reference_id;
END ;

/*
# NAME: edit_order_description
# DESCRIPTION: Edits the description id column from orders table
*/


CREATE PROCEDURE edit_order_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE orders
    SET description = new_description
    WHERE id = reference_id;
END ;

/*
# NAME: edit_department_order_id
# DESCRIPTION: Edits the order id id column from departments table
*/


CREATE PROCEDURE edit_department_order_id (IN new_order_id INT, IN reference_id INT)
BEGIN
    UPDATE departments
    SET order_id = new_order_id
    WHERE id = reference_id;
END ;

/*
# NAME: edit_department_description
# DESCRIPTION: Edits the description column from departments table
*/


CREATE PROCEDURE edit_department_description (IN new_description TEXT, IN reference_id INT)
BEGIN
    UPDATE departments
    SET description = new_description
    WHERE id = reference_id;
END ;