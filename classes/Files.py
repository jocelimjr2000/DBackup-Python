
import json
import os.path
import shutil


class Files:

    # Load config.json
    @staticmethod
    def load_conf_data() -> json:
        config_file = "data/config.json"

        # Check file exists
        if not os.path.isfile(config_file):
            print(">> Config.json not found")
            exit()

        try:
            # Set parameters to data
            with open(config_file) as json_data_file:
                data = json.load(json_data_file)
        except:
            print(">> Invalid Config.json file")
            exit()

        return data

    # Create Folder
    @staticmethod
    def create_folder(folder):
        if not os.path.exists(folder):
            os.makedirs(folder)

    # Delete folder
    @staticmethod
    def delete_folder(folder):
        shutil.rmtree(folder, ignore_errors=True)
