
import os.path
import shutil


class Folder:

    # Create Folder
    def create_folder(self, folder):
        if not os.path.exists(folder):
            os.makedirs(folder)

    # Delete folder
    def delete_folder(self, folder):
        if os.path.isdir(folder):
            shutil.rmtree(folder, ignore_errors=True)
        else:
            os.remove(folder)
