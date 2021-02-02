
from classes.Thread import Thread
from classes.Backup import Backup
from classes.Configfile import Configfile

# Load config.json parameters
config = Configfile()
data = config.load_conf_data()

# Loop Servers
for server in data['servers']:

    # Loop Databases
    for (i, database) in enumerate(server['databases']):
        # Create and start thread
        tmp_thread = Thread(target=Backup.execute, args=(Backup, data['parameters'], server, database))
        tmp_thread.start()
