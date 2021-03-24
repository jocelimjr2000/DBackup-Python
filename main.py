
from classes.Service import Service
import schedule
import time

# schedule.every().hour.do(exec.start())
#
# while True:
#     schedule.run_pending()
#     time.sleep(1)

sv = Service()
sv.start()
