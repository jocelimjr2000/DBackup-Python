import logging
import mysql.connector
from mysql.connector import errorcode
import os.path


class Database:

    # Connection
    @staticmethod
    def connection(self, server, database):
        connection_args = {
            'host': server['host'],
            'database': database,
            'user': server['user'],
            'password': server['password'],
            'port': server['port'],
        }

        try:
            conn = mysql.connector.connect(**connection_args)

            # Log
            logging.info("Server %s Database %s: Connection successful", server["name"], database)

            return conn
        except mysql.connector.Error as err:

            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:

                # Log
                logging.error("Server %s Database %s: Connection error - Something is wrong with your user name or password", server["name"], database)

            elif err.errno == errorcode.ER_BAD_DB_ERROR:

                # Log
                logging.error("Server %s Database %s: Connection error - Database does not exist", server["name"], database)

            else:

                # Log
                logging.error("Server %s Database %s: Connection error - %s", server["name"], database, err)

            return False

    # Dump
    def dump(self, server, folder, database, table=None, routines=True, triggers=True, no_data=False):
        host = server['host']
        user = server['user']
        password = server['password']

        if table is None:
            tmp_folder = os.path.join(folder, database)
            tmp_database = database
        else:
            tmp_folder = os.path.join(folder, table)
            tmp_database = database + ' ' + table

        tmp_routines = '--routines' if routines else ''
        tmp_triggers = '--triggers' if triggers else ''
        tmp_no_data = '--no-data' if no_data else ''

        command = f'mysqldump -h {host} -u {user} -p{password} {tmp_routines} {tmp_triggers} {tmp_no_data} --single-transaction --quick {tmp_database} > {tmp_folder}.sql'

        try:
            if os.system(command) != 0:
                raise Exception()
            else:

                if no_data is True:
                    # Log
                    logging.info("Server %s Database %s: Dump completed (Schema)", server['name'], tmp_database)
                elif table is not None:
                    # Log
                    logging.info("Server %s Database %s: Dump completed (Table %s)", server['name'], tmp_database, table)
                else:
                    # Log
                    logging.info("Server %s Database %s: Dump completed", server['name'], tmp_database)
        except:
            # Log
            logging.error("Server %s Database %s: Dump error", server['name'], tmp_database)
