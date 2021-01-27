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
            _tmpFolder = os.path.join(folder, database)
            _tmpDatabase = database
        else:
            _tmpFolder = os.path.join(folder, table)
            _tmpDatabase = database + ' ' + table

        _tmpRoutines = '--routines' if routines else ''
        _tmpTriggers = '--triggers' if triggers else ''
        _tmpNoData = '--no-data' if no_data else ''

        os.system(f'mysqldump -h {host} -u {user} -p{password} {_tmpRoutines} {_tmpTriggers} {_tmpNoData} --single-transaction --quick {_tmpDatabase} > {_tmpFolder}.sql')
