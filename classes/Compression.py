
from classes.Configfile import Configfile
import shutil
import os.path


class Compression:

    # Define the compression type
    def define_type(self, parameters, server, database):
        compress_type = None
        if 'compressTo' in database and database['compressTo'] is not False:
            compress_type = database['compressTo']
        else:
            if 'compressTo' in server and server['compressTo'] is not False:
                compress_type = server['compressTo']
            else:
                if 'compressTo' in parameters and parameters['compressTo'] is not False:
                    compress_type = parameters['compressTo']

        if compress_type is not None:
            self.check_type(compress_type)

        return compress_type

    # Check type
    def check_type(self, compress_type):
        compress_list = ['zip']

        # Check the compression type
        if compress_type is not None and compress_type not in compress_list:
            print('>> The compression type is invalid')
            exit()

    # Compress to ZIP
    def compress_zip(self, folder):
        # Conf data
        config = Configfile()
        conf_data = config.load_conf_data()

        # File name
        file_name = folder.split('/')

        # Define final file
        file_final = os.path.join(conf_data['parameters']['tmpFolder'], file_name[-2], file_name[-1])

        # Compress
        shutil.make_archive(file_final, 'zip', folder)
