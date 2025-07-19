/*                   TRIGGERS                   */



CREATE TRIGGER trigger_controls_on_events
AFTER UPDATE ON trigger_controls
FOR EACH ROW
BEGIN
	IF NEW.tc_update_features_start_date = 1 AND OLD.tc_update_features_start_date =  0 THEN
        UPDATE features
        SET 
			start_date = (
				SELECT MIN(sf.start_date)
				FROM sub_features sf
				WHERE sf.feature_id = features.id
			),
			duration = DATEDIFF(end_date, start_date)
        WHERE EXISTS (
            SELECT 1 FROM sub_features sf WHERE sf.feature_id = features.id
        );
    END IF;
    

	IF NEW.tc_update_releases_start_date = 1 AND OLD.tc_update_releases_start_date = 0 THEN
	UPDATE releases
	SET 
		start_date = (
			SELECT MIN(f.start_date)
			FROM features f
			WHERE f.release_id = releases.id
		),
		duration = DATEDIFF(end_date, start_date)
	WHERE EXISTS (
		SELECT 1 FROM features f WHERE f.release_id = releases.id
	);
	END IF;


    IF NEW.tc_update_projects_start_date = 1 AND OLD.tc_update_projects_start_date =  0 THEN
        UPDATE projects
        SET 
			start_date = (
				SELECT MIN(r.start_date)
				FROM releases r
				WHERE r.project_id = projects.id
			),
			duration = DATEDIFF(end_date, start_date)
        WHERE EXISTS (
            SELECT 1 FROM releases r WHERE r.project_id = projects.id
        );
    END IF;
    

    IF NEW.tc_update_features_end_date = 1 AND OLD.tc_update_features_end_date = 0 THEN
        UPDATE features
        SET 
			end_date = (
				SELECT MAX(sf.end_date)
				FROM sub_features sf
				WHERE sf.feature_id = features.id
			),
			duration = DATEDIFF(end_date, start_date)
        WHERE EXISTS (
            SELECT 1 FROM sub_features sf WHERE sf.feature_id = features.id
        );
    END IF;
    

    IF NEW.tc_update_releases_end_date = 1 AND OLD.tc_update_releases_end_date = 0 THEN
        UPDATE releases
        SET end_date = (
            SELECT MAX(f.end_date)
            FROM features f
            WHERE f.release_id = releases.id
        ),
        duration = DATEDIFF(end_date, start_date)
        WHERE EXISTS (
            SELECT 1 FROM features f WHERE f.release_id = releases.id
        );
    END IF;


    IF NEW.tc_update_projects_end_date = 1 AND OLD.tc_update_projects_end_date = 0 THEN
        UPDATE projects
        SET end_date = (
            SELECT MAX(r.end_date)
            FROM releases r
            WHERE r.project_id = projects.id
        ),
        duration = DATEDIFF(end_date, start_date)
        WHERE EXISTS (
            SELECT 1 FROM releases r WHERE r.project_id = projects.id
        );
    END IF;
END ;



CREATE TRIGGER calc_subfs_end_date_insert
BEFORE INSERT ON sub_features
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;



CREATE TRIGGER calc_features_end_date_insert
BEFORE INSERT ON features
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;



CREATE TRIGGER calc_releases_end_date_insert
BEFORE INSERT ON releases
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;

CREATE TRIGGER calc_projects_end_date_insert
BEFORE INSERT ON projects
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;








CREATE TRIGGER calc_subfs_end_date_update
BEFORE UPDATE ON sub_features
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;


CREATE TRIGGER calc_features_end_date_update
BEFORE UPDATE ON features
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;


CREATE TRIGGER calc_releases_end_date_update
BEFORE UPDATE ON releases
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;


CREATE TRIGGER calc_projects_end_date_update
BEFORE UPDATE ON projects
FOR EACH ROW
BEGIN
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL NEW.duration DAY);
END ;

