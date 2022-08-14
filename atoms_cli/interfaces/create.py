import sys
from enum import Enum

from atoms_cli.utils.print import Print
from atoms_cli.utils.atom_types import atom_types


class CreateAtom:

    def __init__(self, atoms_backend: 'AtomsBackend', args: 'argparse.Namespace'):
        self.__atoms_backend = atoms_backend
        self.__args = args
        self.__validate_args()
    
    def __validate_args(self):
        if self.__args.type not in atom_types:
            Print.stderr("Invalid atom type. Supported types: {}.".format(str_atom_types))

    def run(self):
        Print.stdout("interface: CreateAtom", exit=True)
