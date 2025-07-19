/*                   TABLE'S                   */

CREATE TABLE trigger_controls (
    tc_update_features_start_date_up BOOLEAN NOT NULL DEFAULT 0,
    tc_update_releases_start_date_up BOOLEAN NOT NULL DEFAULT 0,
    tc_update_features_end_date_up BOOLEAN NOT NULL DEFAULT 0,
	tc_update_releases_end_date_up BOOLEAN NOT NULL DEFAULT 0,
    
    
    tc_update_features_start_date_down BOOLEAN NOT NULL DEFAULT 0,
    tc_update_subf_start_date_down BOOLEAN NOT NULL DEFAULT 0,
    tc_update_features_end_date_down BOOLEAN NOT NULL DEFAULT 0,
	tc_update_releases_end_date_down BOOLEAN NOT NULL DEFAULT 0
);

INSERT INTO trigger_controls VALUES ();

CREATE TABLE departments (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    #order_id INT,
    # Something with employees
    description TEXT
    #FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
/* 
    Add parent to releases called projects.
    Add departments to project, releases, features, and sub features.

*/
CREATE TABLE releases (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT
);

CREATE TABLE features (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    release_id INT NOT NULL,
	start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT,
    FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE
);

CREATE TABLE sub_features (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    feature_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT,
    FOREIGN KEY (feature_id) REFERENCES features(id) ON DELETE CASCADE
);

CREATE TABLE materials (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    price DECIMAL(11,2),
    capex_or_opex BOOLEAN,
    internal_or_external BOOLEAN,
    description TEXT
);

CREATE TABLE orders (
	po_number VARCHAR(25),
	id INT AUTO_INCREMENT PRIMARY KEY,
	department_id INT,
	material_id INT,
	feature_id INT,
	sub_feature_id INT,
	quantity INT,
    date_ordered_by DATE,
    date_needed_by DATE,
	description TEXT,
	FOREIGN KEY (department_id) REFERENCES departments(id),
	FOREIGN KEY (material_id) REFERENCES materials(id),
	FOREIGN KEY (feature_id) REFERENCES features(id),
    FOREIGN KEY (sub_feature_id) REFERENCES sub_features(id)
);