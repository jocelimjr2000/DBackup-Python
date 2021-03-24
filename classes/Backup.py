
import os.path
from datetime import datetime
from classes.Database import Database
from classes.Folder import Folder
from classes.Move import Move
from classes.Compression import Compression
import logging


class Backup:

    # Execute backup
    def execute(self, parameters: object, server: object, database: object, dt_string: datetime):
        # Set DB Name
        if 'name' in database:
            database_name = database['name']
        else:
            database_name = database

        # Log
        logging.info("Server %s Database %s: Start Backup", server["name"], database_name)

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
        compress_type = comp.define_type(parameters, server, database_name)

        # Create Connection
        conn = Database.connection(self, server, database_name)

        # Check Connection
        if conn:

            # Define base folder
            db_folder = server['prefix'] + database_name
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
                Database.dump(self, server=server, folder=base_folder, database=database_name, no_data=True)

                # List Tables
                cursor.execute("show full tables where Table_Type != 'VIEW' ")
                tables = cursor.fetchall()

                # Dump Tables
                for k in tables:
                    Database.dump(self, server=server, folder=folder_tables, database=database_name, table=k[0], routines=False, triggers=False)

            # Export database (unique file)
            else:
                # Create folder
                folder.create_folder(base_folder)

                # Dump
                Database.dump(self, server=server, folder=base_folder, database=database_name)

            # Check compress type
            if compress_type is not None:
                # Compress folder
                if compress_type == 'zip':
                    comp.compress_zip(server, base_folder, database_name)

                # Delete tmp files
                folder.delete_folder(base_folder)

            # Move
            # mv = Move()
            # mv.move_to_storage(base_folder, compress_type)

            # End process
            conn.close()

        else:
            return False
