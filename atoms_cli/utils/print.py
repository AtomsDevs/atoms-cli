import sys


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

        max_lengths = [max(len(row[i]) for row in rows) for i in range(len(columns))]

        Print.stdout("|", new_line=False)
        for i in range(len(columns)):
            Print.stdout(f" {columns[i]} ", new_line=False)
            Print.stdout(" " * (max_lengths[i] - len(columns[i])), new_line=False)
            Print.stdout("|", new_line=False)

        Print.stdout("\n")

        for row in rows:
            Print.stdout("|", new_line=False)
            for i in range(len(row)):
                Print.stdout( f" {row[i]} ", new_line=False)
                Print.stdout(" " * (max_lengths[i] - len(row[i])), new_line=False)
                Print.stdout("|", new_line=False)
                
            Print.stdout("\n")


        Print.exit(exit)
