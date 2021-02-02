
import json
import os.path


class Configfile:
    __data: json

    def __init__(self):
        config_file = "data/config.json"

        # Check file exists
        if not os.path.isfile(config_file):
            print(">> Config.json not found")
            exit()

        try:
            # Set parameters to data
            with open(config_file) as json_data_file:
                self.__data = json.load(json_data_file)
        except:
            print(">> Invalid Config.json file")
            exit()

    # Load config.json
    def load_conf_data(self) -> json:
        return self.__data
