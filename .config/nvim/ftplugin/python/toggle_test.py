import os
import pathlib

import vim

def is_a_python_file(buffername):
    return buffername and buffername.suffix == '.py'

def is_a_test(path):
    '''
    Returns true if the given Path is named like a Python test file,
    false otherwise.
    '''
    assert path.suffix == '.py', path
    return (
        path.name.startswith('test') or
        path.name.endswith('test') or
        path.name.endswith('tests')
    )

def get_test(impl):
    '''
    Given the name of an implementation file (e.g. foo/x.py)
    returns the name of the corresponding unit test
    (e.g. foo/tests/test_x.py if tests subdir exists, foo/test_x.py otherwise)
    '''
    impl_dir = pathlib.Path(*impl.parts[:-1])
    test_subdir = impl_dir / 'tests'
    test_dir = test_subdir if test_subdir.exists() else impl_dir
    test = test_dir / ('test_' + impl.name)
    return test.relative_to(pathlib.Path.cwd())

def get_impl(test):
    '''
    Given the name of a test file (e.g. foo/tests/test_x.py)
    returns the name of the corresponding implementation file (e.g. foo/x.py)
    '''
    assert test.name.startswith('test_'), test.name
    path_prefixes = 2 if test.parts[-2] == 'tests' else 1
    impl = pathlib.Path(*test.parts[:-path_prefixes], test.name[5:])
    return impl.relative_to(pathlib.Path.cwd())

def open_file(name):
    vim.command('hide edit {}'.format(name))

def toggle_test():
    current = pathlib.Path(vim.current.buffer.name)

    if not is_a_python_file(current):
        print('is not a Python file')
        return

    to_open = get_impl(current) if is_a_test(current) else get_test(current)
    open_file(to_open)

