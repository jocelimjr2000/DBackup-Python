from datetime import datetime
from classes.Thread import Thread
from classes.Backup import Backup
from classes.Configfile import Configfile
import logging.config


class Service:
    __config = None
    __ref = None

    def __init__(self):
        # Load config.json parameters
        self.__config = Configfile().load_conf_data()

        # Set reference (Date and Hour)
        now = datetime.now()
        self.__ref = now.strftime("%Y_%m_%d__%H")

        # Configure logging
        log_folder = self.__config['parameters']['logFolder']
        file_name = self.__ref + '.log'

        if not log_folder[0:-1] == '/':
            log_folder = log_folder + '/'

        logging.basicConfig(
            format='%(asctime)s - %(levelname)s - %(message)s',
            filename=log_folder + file_name,
            encoding='utf-8',
            level=logging.DEBUG,
            datefmt='%d/%m/%Y %H:%I:%S'
        )

    def start(self):
        # Log
        logging.info('Start process')

        threads_list = []

        # Loop Servers and push on threads list
        for server in self.__config['servers']:

            # Create and Start Threads
            for (i, database) in enumerate(server['databases']):
                tmp_thread = Thread(target=Backup.execute, name=server['name'] + "|" + database['name'],
                                    args=(Backup, self.__config['parameters'], server, database, self.__ref))
                threads_list.append(tmp_thread)
                tmp_thread.start()

        # Start all threads
        for t in threads_list:
            t.join()

            name = t.getName().split("|")

            # Log
            logging.info("Server %s Database %s: Finish Backup", name[0], name[1])

        logging.info('Finish process')
