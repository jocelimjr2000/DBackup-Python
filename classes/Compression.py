
from classes.Files import Files
import shutil
import os.path


class Compression:

    # Check type
    @staticmethod
    def check_type(compress_type):
        compress_list = ['zip']

        # Check the compression type
        if compress_type is not None and compress_type not in compress_list:
            print('>> The compression type is invalid')
            exit()

    # Compress to ZIP
    @staticmethod
    def compress_zip(folder):
        # Conf data
        conf_data = Files.load_conf_data()

        # File name
        file_name = folder.split('/').pop()

        # Define final file
        file_final = os.path.join(conf_data['parameters']['tmpFolder'], file_name)

        # Compress
        shutil.make_archive(file_final, 'zip', folder)
