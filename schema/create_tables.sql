/*                   TABLE'S                   */

CREATE TABLE trigger_controls (
    tc_update_features_start_date BOOLEAN NOT NULL DEFAULT 0,
    tc_update_releases_start_date BOOLEAN NOT NULL DEFAULT 0,
    tc_update_projects_start_date BOOLEAN NOT NULL DEFAULT 0,
    
    tc_update_features_end_date BOOLEAN NOT NULL DEFAULT 0,
	tc_update_releases_end_date BOOLEAN NOT NULL DEFAULT 0,
    tc_update_projects_end_date BOOLEAN NOT NULL DEFAULT 0
);

INSERT INTO trigger_controls VALUES ();



CREATE TABLE projects (
    name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT
);

CREATE TABLE releases (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
	start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE features (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    release_id INT,
	start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT,
    FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE
);

CREATE TABLE sub_features (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    feature_id INT,
    start_date DATE,
    end_date DATE,
    duration INT,
    description TEXT,
    FOREIGN KEY (feature_id) REFERENCES features(id) ON DELETE CASCADE
);


CREATE TABLE departments (
	name VARCHAR(50) NOT NULL UNIQUE,
    id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT
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
    release_id INT,
	feature_id INT,
	sub_feature_id INT,
	quantity INT,
    date_ordered_by DATE,
    date_needed_by DATE,
	description TEXT,
	FOREIGN KEY (department_id) REFERENCES departments(id),
	FOREIGN KEY (material_id) REFERENCES materials(id),
    FOREIGN KEY (release_id) REFERENCES releases(id),
	FOREIGN KEY (feature_id) REFERENCES features(id),
    FOREIGN KEY (sub_feature_id) REFERENCES sub_features(id)
);
