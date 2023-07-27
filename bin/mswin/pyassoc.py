""" Change the .py file extension to point to a different
    Python installation.
"""
import _winreg as reg
import sys

pydir = sys.argv[1]

todo = [
    ('Applications\python.exe\shell\open\command',
                '"PYDIR\\python.exe" "%1" %*'),
    ('Applications\pythonw.exe\shell\open\command',
                '"PYDIR\\pythonw.exe" "%1" %*'),
    ('Python.CompiledFile\DefaultIcon',
                'PYDIR\\pyc.ico'),
    ('Python.CompiledFile\shell\open\command',
                '"PYDIR\\python.exe" "%1" %*'),
    ('Python.File\DefaultIcon',
                'PYDIR\\py.ico'),
    ('Python.File\shell\open\command',
                '"PYDIR\\python.exe" "%1" %*'),
    ('Python.NoConFile\DefaultIcon',
                'PYDIR\\py.ico'),
    ('Python.NoConFile\shell\open\command',
                '"PYDIR\\pythonw.exe" "%1" %*'),
    ]

classes_root = reg.OpenKey(reg.HKEY_CLASSES_ROOT, "")
for path, value in todo:
    key = reg.OpenKey(classes_root, path, 0, reg.KEY_SET_VALUE)
    reg.SetValue(key, '', reg.REG_SZ, value.replace('PYDIR', pydir))

