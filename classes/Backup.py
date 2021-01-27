import os.path
from classes.Database import Database
from classes.Files import Files
from datetime import datetime


class Backup:

    # Execute backup
    def execute(self, parameters: object, server: object, database: object):

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
            base_folder = os.path.join(parameters['tmpFolder'], dt_string, server['prefix'] + database)

            # Export database (separated files)
            if separated_files:

                # Define Sub Folder
                folder_tables = os.path.join(base_folder, 'tables')

                # Create folder
                Files.create_folder(folder_tables)

                cursor = conn.cursor()

                # Dump Database Schema
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
                Files.create_folder(base_folder)

                # Dump
                Database.dump(self, base_folder, server['host'], server['user'], server['password'], database)

            # Compact databases

            # Delete tmp files

            # Set Disk

            # Move

            # End process
            conn.close()

        else:
            print(">> Not Connected")
