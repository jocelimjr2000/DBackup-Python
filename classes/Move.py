
from classes.Configfile import Configfile
from classes.Folder import Folder
import shutil
import os


class Move:

    # Move to storage folder
    def move_to_storage(self, ref, compress_type):
        conf = Configfile()
        data = conf.load_conf_data()
        p = ref.split('/')

        # Move to folder
        # if data['storage']['type'] == "folder":
        #     if compress_type is None:
        #         shutil.copytree(ref, os.path.join(data['storage']['to'], p[-2], p[-1]), dirs_exist_ok=True)
        #         Folder.delete_folder(self, ref)
        #     else:
        #         shutil.copy2(ref + '.' + compress_type, os.path.join(data['storage']['to'], p[-2]))
        #         Folder.delete_folder(self, ref + '.' + compress_type)
