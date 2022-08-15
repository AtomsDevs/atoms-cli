import sys
from tabulate import tabulate


class Print:

    @staticmethod
    def exit(exit: bool=True):
        if exit:
            sys.exit(0)

    @staticmethod
    def stderr(msg: str, new_line: bool=True, exit: bool=True):
        sys.stderr.write("⚠️  \033[91m{}\033[0m\n".format(msg))
        if new_line:
            sys.stderr.write("\n")
        Print.exit(exit)

    @staticmethod
    def stdout(msg: str, new_line: bool=True, exit: bool=False):
        sys.stdout.write(f"{msg}")
        if new_line:
            sys.stdout.write("\n")
        Print.exit(exit)
    
    @staticmethod
    def table(columns: list, rows: list, exit: bool=False):
        if len(columns) != len(rows[0]):
            Print.stderr("Invalid table. Columns and rows must have the same length.")
            
        Print.stdout(tabulate(rows, headers=columns))
        if exit:
            Print.exit()
