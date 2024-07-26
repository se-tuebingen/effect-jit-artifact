# Some patches for the debugger, to make sure deepcopy works on certain kinds of RPython objects

from rpython.rlib import rfile
rfile.RFile.__deepcopy__ = lambda self, memo: self