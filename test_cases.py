'''             TEST CASES             '''

import unittest
import mysql.connector


''' 

The edit_end_date functions need a better way to confirm if the duration was calculated properly.

Update the end_date calculator built in to remove unnessary triggers


'''

class TestDatabaseProcedures(unittest.TestCase):

    def setUp(self):
        """This runs before each test method."""
        self.conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="password",
            database="bpc",
            port=3306
        )
        self.cursor = self.conn.cursor()

    def tearDown(self):
        """This runs after each test method."""
        self.conn.commit()
        self.cursor.close()
        self.conn.close()





    "~~~ Releases ~~~"

    def test_add_new_release(self):
        
        self.cursor.execute("DELETE FROM releases WHERE name = 'UnitTest Add Release';")
        args = ('UnitTest Add Release', '2025-01-01', 10, 'Test Description')
        self.cursor.callproc('add_new_release', args)

        self.cursor.execute("SELECT * FROM releases WHERE name = 'UnitTest Add Release';")
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
        # Still needs the date_mover checker.
    


    def test_delete_release(self):
        
        self.cursor.execute(
        "INSERT INTO releases (name, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s);",
        ("UnitTest Delete Release", "2025-01-01", 10, "Test Description"))
        
        release_id = self.cursor.lastrowid
        args = (release_id,)

        self.cursor.callproc('delete_release', args)
        self.cursor.execute("SELECT * FROM releases WHERE name = %s AND id = %s",
                            ("UnitTest Delete Release", release_id))

        result = self.cursor.fetchall()
        self.assertEqual(len(result), 0)
    
    

    def test_edit_release_name(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.callproc("edit_release_name", ("Updated Name", release_id))
        self.cursor.execute("SELECT * FROM releases WHERE name = %s AND id = %s",
                            ("Updated Name", release_id))

        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
    
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))




    def test_edit_release_start_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.callproc("edit_release_start_date", ("2026-01-01", release_id))
        self.cursor.execute("SELECT * FROM releases WHERE start_date = %s AND id = %s",
                            ("2026-01-01", release_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))



    
    def test_edit_release_end_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.callproc("edit_release_end_date", ("2026-01-01", release_id))
        self.cursor.execute("SELECT * FROM releases WHERE end_date = %s AND duration = %s AND id = %s",
                            ("2026-01-01", 365, release_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
    


    # Might want to change this for the other tests

    def test_edit_release_duration(self):
    
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing")
        )

        release_id = self.cursor.lastrowid

        self.cursor.callproc("edit_release_duration", (27, release_id))
        self.cursor.execute("SELECT start_date, duration, end_date FROM releases WHERE id = %s", (release_id,))
        
        result = self.cursor.fetchone()
        self.assertIsNotNone(result)

        start_date, duration, end_date = result

        self.assertEqual(duration, 27)
        self.assertEqual(str(end_date), "2025-01-28") 

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))




    def test_edit_release_description(self):
    
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.callproc("edit_release_description", ("New description",release_id))
        self.cursor.execute("SELECT * FROM releases WHERE description = %s AND id = %s",
                            ("New description", release_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
    




    

    def test_reject_negative_duration_release(self):
            
        with self.assertRaises(mysql.connector.Error):
            args = ('Bad release', 1, '2025-01-01', -5, 'Should Fail')
            self.cursor.callproc('add_new_release', args)
        # This will also check if the edit_feature_duration can be negative





    "~~~ Features ~~~"
    
    """Test if the stored procedure adds a new sub_feature correctly."""
    def test_add_new_feature(self):
        
        self.cursor.execute("DELETE FROM features WHERE name = 'UnitTest Feature';")
        args = ('UnitTest Add Feature', 1, '2025-01-01', 10, 'Test Description')
        self.cursor.callproc('add_new_feature', args)

        self.cursor.execute("SELECT * FROM features WHERE name = 'UnitTest Add Feature';")
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
        # Still needs the date_mover checker.
    

    
    def test_delete_feature(self):
        
        self.cursor.execute(
        "INSERT INTO releases (name, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s);",
        ("UnitTest Delete Feature R", "2025-01-01", 10, "Test Description"))

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("UnitTest Delete Feature", release_id, "2025-01-01", 10, "Test Description"))
    
        feature_id = self.cursor.lastrowid
        args = (feature_id,)
        
        self.cursor.callproc('delete_feature', args)
        self.cursor.execute("SELECT * FROM features WHERE name = %s AND id = %s",
                            ("UnitTest Delete Feature", feature_id))

        result = self.cursor.fetchall()
        self.assertEqual(len(result), 0)
        
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))




    def test_edit_feature_name(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_name", ("Updated Name", feature_id))
        self.cursor.execute("SELECT * FROM features WHERE name = %s AND id = %s",
                            ("Updated Name", feature_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
        
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))




    def test_edit_feature_associated_release_id(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            (" Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Secondary Name R", "2025-01-01", 10, "Edit test description")
        )

        second_release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_associated_release_id", (second_release_id, feature_id))
        self.cursor.execute("SELECT * FROM features WHERE release_id = %s AND id = %s",
                            (second_release_id, feature_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (second_release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))




    
    def test_edit_feature_start_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_start_date", ("2026-01-01", feature_id))
        self.cursor.execute("SELECT * FROM features WHERE start_date = %s AND id = %s",
                            ("2026-01-01", feature_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
    


    def test_edit_feature_end_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_end_date", ("2026-01-01", feature_id))
        self.cursor.execute("SELECT * FROM features WHERE end_date = %s AND duration = %s AND id = %s",
                            ("2026-01-01", 365, feature_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
    
    

    
    def test_edit_feature_duration(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing end_date")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_duration", (27, feature_id))
        self.cursor.execute("SELECT start_date, duration, end_date FROM features WHERE id = %s", (feature_id,))

        result = self.cursor.fetchone()
        self.assertIsNotNone(result)

        start_date, duration, end_date = result

        self.assertEqual(duration, 27)
        self.assertEqual(str(end_date), "2025-01-28") 
        
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
    
    
    def test_edit_feature_description(self):
    
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Testing description"))

        feature_id = self.cursor.lastrowid

        self.cursor.callproc("edit_feature_description", ("New description",feature_id))
        self.cursor.execute("SELECT * FROM features WHERE description = %s AND id = %s",
                            ("New description", feature_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))


        

    def test_reject_negative_duration_feature(self):
        
        with self.assertRaises(mysql.connector.Error):
            args = ('Bad Feature', 1, '2025-01-01', -5, 'Should Fail')
            self.cursor.callproc('add_new_feature', args)
        # This will also check if the edit_feature_duration can be negative






    "~~~ Sub_Features ~~~"

    """Test if the stored procedure adds a new sub_feature correctly."""
    def test_add_new_subf(self):
        
        self.cursor.execute("DELETE FROM sub_features WHERE name = 'UnitTest Sub';")
        args = ('UnitTest Add Sub', 1, '2025-01-01', 10, 'Test Description')
        self.cursor.callproc('add_new_sub_feature', args)

        self.cursor.execute("SELECT * FROM sub_features WHERE name = 'UnitTest Add Sub';")
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
        # Still needs the date_mover checker.

    
    def test_delete_subf(self):
        
        self.cursor.execute(
        "INSERT INTO releases (name, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s);",
        ("UnitTest Delete Subf R", "2025-01-01", 10, "Test Description"))

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("UnitTest Delete Subf F", release_id, "2025-01-01", 10, "Test Description"))
    
        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("UnitTest Delete Subf Sf", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid
        args = (subf_id,)

        self.cursor.callproc('delete_feature', args)
        self.cursor.execute("SELECT * FROM releases WHERE name = %s AND id = %s",
                            ("UnitTest Delete Subf Sf", subf_id))

        result = self.cursor.fetchall()
        self.assertEqual(len(result), 0)
        
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))



    def test_edit_subf_name(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid
        
        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("UnitTest Delete Subf Sf", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid

        self.cursor.callproc("edit_sub_feature_name", ("Updated Name", subf_id))
        self.cursor.execute("SELECT * FROM sub_features WHERE name = %s AND id = %s",
                            ("Updated Name", subf_id))

        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)
        
        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))




    def test_edit_subf_associated_feature_id(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Secondary Name F", release_id, "2025-01-01", 10, "Test Description"))

        second_feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name R", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid

        self.cursor.callproc("edit_sub_feature_associated_feature_id", (second_feature_id, subf_id))
        self.cursor.execute("SELECT * FROM sub_features WHERE feature_id = %s AND id = %s",
                            (second_feature_id, subf_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (second_feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))




    def test_edit_subf_start_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))
        
        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name Sf", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid

        self.cursor.callproc("edit_sub_feature_start_date", ("2026-01-01", subf_id))
        self.cursor.execute("SELECT * FROM sub_features WHERE start_date = %s AND id = %s",
                            ("2026-01-01", subf_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))



    def test_edit_subf_end_date(self):
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Edit test description")
        )

        release_id = self.cursor.lastrowid
        
        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name Sf", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid

        self.cursor.callproc("edit_sub_feature_end_date", ("2026-01-01", subf_id))
        self.cursor.execute("SELECT * FROM sub_features WHERE end_date = %s AND duration = %s AND id = %s",
                            ("2026-01-01", 365, subf_id))
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))
    



    def test_edit_subf_duration(self):
    # Step 1: Insert a test release
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing end_date")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Test Description"))

        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name Sf", feature_id, "2025-01-01", 10, "Test Description"))

        subf_id = self.cursor.lastrowid

        self.cursor.callproc("edit_sub_feature_duration", (27, subf_id))
        self.cursor.execute("SELECT start_date, duration, end_date FROM sub_features WHERE id = %s", (subf_id,))
        
        result = self.cursor.fetchone()
        self.assertIsNotNone(result)

        start_date, duration, end_date = result

        self.assertEqual(duration, 27)
        self.assertEqual(str(end_date), "2025-01-28") 

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))



    def test_edit_subf_description(self):
    
        self.cursor.execute(
            "INSERT INTO releases (name, start_date, duration, description) "
            "VALUES (%s, %s, %s, %s);",
            ("Original Name R", "2025-01-01", 10, "Testing description")
        )

        release_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO features (name, release_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name F", release_id, "2025-01-01", 10, "Testing description"))

        feature_id = self.cursor.lastrowid

        self.cursor.execute(
        "INSERT INTO sub_features (name, feature_id, start_date, duration, description) "
        "VALUES (%s, %s, %s, %s, %s);",
        ("Original Name Sf", feature_id, "2025-01-01", 10, "Testing description"))

        subf_id = self.cursor.lastrowid


        self.cursor.callproc("edit_sub_feature_description", ("New description",subf_id))
        self.cursor.execute("SELECT * FROM sub_features WHERE description = %s AND id = %s",
                            ("New description", subf_id))
        
        
        result = self.cursor.fetchall()
        self.assertEqual(len(result), 1)

        self.cursor.execute("DELETE FROM releases WHERE id = %s", (release_id,))
        self.cursor.execute("DELETE FROM features WHERE id = %s", (feature_id,))
        self.cursor.execute("DELETE FROM sub_features WHERE id = %s", (subf_id,))
    
    def test_reject_negative_duration_subf(self):
        
        with self.assertRaises(mysql.connector.Error):
            args = ('Bad Sub', 1, '2025-01-01', -5, 'Should Fail')
            self.cursor.callproc('add_new_sub_feature', args)
        # This will also check if the edit_subf_duration can be negative




def suite():
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Run these tests first, in specific order
    suite.addTest(TestDatabaseProcedures('test_add_new_release'))
    suite.addTest(TestDatabaseProcedures('test_add_new_feature'))
    suite.addTest(TestDatabaseProcedures('test_add_new_subf'))
    

    # Add the remaining tests (automatically discovered)
    all_tests = loader.loadTestsFromTestCase(TestDatabaseProcedures)

    for test in all_tests:
        if test._testMethodName not in ['test_add_new_release','test_add_new_feature','test_add_new_subf']:
            suite.addTest(test)

    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner()
    runner.run(suite())





























'''
def runTestCases():
    
    print("Choose what to run:\n" \
          "1.Run all tests\n" \
          "2.Run an individual test\n" \
          "3. Exit"
         )
    userChoice = input()

    # Runs all test cases
    if userChoice == 1:
        print("A")
        # TEST FUNCTIONS

    # Allows operator to choose which individual test they want to run
    elif userChoice == 2:
        print("Choose what test to run:\n" \
        "1. ____")
        userChoice1 = input()
    
    # Exits program
    elif userChoice == 3:
        exit()

    # Error statement
    else:
        print("Please enter either 1, 2, or 3. No other entries will be accepted")
'''