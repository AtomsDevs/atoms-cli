import sys
import shlex
from enum import Enum

from atoms_core.utils.distribution import AtomsDistributionsUtils
from atoms_core.utils.command import CommandUtils

from atoms_cli.utils.print import Print
from atoms_cli.utils.atom_types import atom_types
from atoms_cli.utils.generic import emojify_atom_name


class EnterAtom:

    def __init__(self, atoms_backend: 'AtomsBackend', args: 'argparse.Namespace'):
        self.__atoms_backend = atoms_backend
        self.__args = args
        self.__validate_args()
    
    def __validate_args(self):
        if self.__args.aid and self.__args.name:
            Print.stderr('You can only specify one of --aid or --name')

        if not self.__args.aid and not self.__args.name:
            Print.stderr('You must specify one of --aid or --name')

        if self.__args.command == "exec":
            if not self.__args.input:
                Print.stderr('You must specify --input when executing a command')
    
    def run(self):
        atom = None
        lookup_by = None

        for _atom in self.__atoms_backend.atoms.values():
            if self.__args.aid:
                lookup_by = 'aid'
                if _atom.aid.startswith(self.__args.aid):
                    atom = _atom
                    break
            elif self.__args.name:
                lookup_by = 'name'
                if _atom.name == self.__args.name:
                    atom = _atom
                    break

        if not atom:
            Print.stderr('No atom found with {} {}'.format(lookup_by, self.__args.aid or self.__args.name))
            sys.exit(1)

        if self.__args.command == "enter":
            Print.stdout('Launching an Atom Console for {} {}'.format(lookup_by, atom.name))
            command, _, _ = atom.untracked_enter_command
            CommandUtils.check_call(command, ignore_errors=True)
            Print.stdout('Atom Console with {} {} exited.'.format(lookup_by, atom.name))
        elif self.__args.command == "exec":
            Print.stdout('Executing a command in {} {}'.format(lookup_by, atom.name))
            command, _, _ = atom.generate_command(self.__args.input, track_exit=False)
            CommandUtils.check_call(command, ignore_errors=True)
            Print.stdout('Command executed in {} {}'.format(lookup_by, atom.name))
