
import logging
from classes.Configfile import Configfile
import shutil
import os.path


class Compression:

    # Define the compression type
    def define_type(self, parameters, server, database):
        compress_list = ['zip']
        compress_type = None

        if 'compressTo' in database and database['compressTo'] is not False:
            compress_type = database['compressTo']
        else:
            if 'compressTo' in server and server['compressTo'] is not False:
                compress_type = server['compressTo']
            else:
                if 'compressTo' in parameters and parameters['compressTo'] is not False:
                    compress_type = parameters['compressTo']

        if compress_type is not None and compress_type not in compress_list:
            compress_type = None

        return compress_type

    # Compress to ZIP
    def compress_zip(self, server, folder, database):
        # Conf data
        config = Configfile()
        conf_data = config.load_conf_data()

        # File name
        file_name = folder.split('/')

        # Define final file
        file_final = os.path.join(conf_data['parameters']['tmpFolder'], file_name[-2], file_name[-1])

        # Compress
        try:
            shutil.make_archive(file_final, 'zip', folder)
            # Log
            logging.info("Server %s Database %s: Compressing completed", server['name'], database)
        except:
            # Log
            logging.error("Server %s Database %s: Compressing error", server['name'], database)
