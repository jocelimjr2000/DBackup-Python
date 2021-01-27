
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
            return conn
        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                print(">> Something is wrong with your user name or password")
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                print(">> Database does not exist")
            else:
                print(err)

            conn.close()
            return False

    # Dump
    def dump(self, folder, host, user, password, database, table=None, routines=True, triggers=True, no_data=False):
        if table is None:
            tmp_folder = os.path.join(folder, database)
            tmp_database = database
        else:
            tmp_folder = os.path.join(folder, table)
            tmp_database = database + ' ' + table

        tmp_routines = '--routines' if routines else ''
        tmp_triggers = '--triggers' if triggers else ''
        tmp_no_data = '--no-data' if no_data else ''

        os.system(f'mysqldump -h {host} -u {user} -p{password} {tmp_routines} {tmp_triggers} {tmp_no_data} --single-transaction --quick {tmp_database} > {tmp_folder}.sql')
