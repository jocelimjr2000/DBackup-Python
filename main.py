
from classes.Threads import Threads
from classes.Backup import Backup
from classes.Files import Files

# Load config.json parameters
data = Files.load_conf_data()

# Loop Servers
for server in data['servers']:

    # Loop Databases
    for (i, database) in enumerate(server['databases']):
        # Create and start thread
        tmp_thread = Threads(target=Backup.execute, args=(Backup, data['parameters'], server, database))
        tmp_thread.start()
