
import os.path
from datetime import datetime
from classes.Database import Database
from classes.Folder import Folder
from classes.Move import Move
from classes.Compression import Compression


class Backup:

    # Execute backup
    def execute(self, parameters: object, server: object, database: object):

        # Objects
        comp = Compression()
        folder = Folder()

        # Define export type
        separated_files = False
        if 'separatedFiles' in database:
            if database['separatedFiles']:
                separated_files = True
        else:
            if 'separatedFiles' in server:
                if server['separatedFiles']:
                    separated_files = True
            else:
                if parameters['separatedFiles']:
                    separated_files = True

        # Define the compression type
        compress_type = comp.define_type(parameters, server, database)

        # Check DB Name
        if 'name' in database:
            database = database['name']

        # Create Connection
        conn = Database.connection(self, server, database)

        # Check Connection
        if conn:

            # Date and Hour
            now = datetime.now()
            dt_string = now.strftime("%Y_%m_%d__%H")

            # Define base folder
            db_folder = server['prefix'] + database
            tmp_folder = os.path.join(parameters['tmpFolder'], dt_string)
            base_folder = os.path.join(tmp_folder, db_folder)

            # Export database (separated files)
            if separated_files:

                # Define Sub Folder
                folder_tables = os.path.join(base_folder, 'tables')

                # Create folder
                folder.create_folder(folder_tables)

                cursor = conn.cursor()

                # Dump Schema
                Database.dump(self, base_folder, server['host'], server['user'], server['password'], database, None, True, True, True)

                # List Tables
                cursor.execute("show full tables where Table_Type != 'VIEW' ")
                tables = cursor.fetchall()

                # Dump Tables
                for k in tables:
                    Database.dump(self, folder_tables, server['host'], server['user'], server['password'], database, k[0], False, False)

            # Export database (unique file)
            else:
                # Create folder
                folder.create_folder(base_folder)

                # Dump
                Database.dump(self, base_folder, server['host'], server['user'], server['password'], database)

            # Check compress type
            if compress_type is not None:
                # Compress folder
                if compress_type == 'zip':
                    comp.compress_zip(base_folder)

                # Delete tmp files
                folder.delete_folder(base_folder)

            # Move
            # mv = Move()
            # mv.move_to_storage(base_folder, compress_type)

            # End process
            conn.close()

        else:
            print(">> Not Connected")
