
from threading import Thread as Th


class Thread(Th):
    _return: object

    def __init__(self, group=None, target=None, name=None, args=(), kwargs={}):
        Th.__init__(self, group, target, name, args, kwargs)

    def run(self):
        if self._target is not None:
            self._return = self._target(*self._args, **self._kwargs)

    def join(self, *args):
        Th.join(self, *args)
        return self._return
