/*                   DEPARTMENT'S PROCEDURES                   */

/*
# NAME: add_new_department
# DESCRIPTION: Add new item to departments tables
*/


CREATE PROCEDURE add_new_department (IN department_name VARCHAR(50), IN department_description TEXT)
BEGIN
	INSERT INTO departments (name, description)
    VALUES (department_name, IFNULL(department_description, "Description"));
END ;


/*
# NAME: delete_department
# DESCRIPTION: Deletes a row from departments table
*/


CREATE PROCEDURE delete_department (IN selected_id INT)
BEGIN
    DELETE FROM departments
    WHERE id = selected_id;
END ;
