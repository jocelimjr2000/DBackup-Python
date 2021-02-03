from classes.Thread import Thread
from classes.Backup import Backup
from classes.Configfile import Configfile
import logging.config


def start():
    # Load config.json parameters
    config = Configfile()
    data = config.load_conf_data()

    # Configure logging
    logging.config.fileConfig('./logging.conf')

    # Log
    logging.info('Start process')

    threads_list = []

    # Loop Servers
    for server in data['servers']:

        # Create and Start Threads
        for (i, database) in enumerate(server['databases']):
            tmp_thread = Thread(target=Backup.execute, name=server['name'] + "|" + database['name'],
                                args=(Backup, data['parameters'], server, database))
            threads_list.append(tmp_thread)
            tmp_thread.start()

    for t in threads_list:
        t.join()

        name = t.getName().split("|")

        # Log
        logging.info("Server %s Database %s: Finish Backup", name[0], name[1])

    logging.info('Finish process')
