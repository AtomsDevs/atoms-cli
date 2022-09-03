import sys
import datetime

from atoms_cli.utils.print import Print
from atoms_cli.utils.generic import emojify_atom_name
from atoms_cli.utils.atom_types import atom_types, str_atom_types


class ListAtom:

    def __init__(self, atoms_backend: 'AtomsBackend', args: 'argparse.Namespace'):
        self.__atoms_backend = atoms_backend
        self.__args = args
        self.__validate_args()

    def __validate_args(self):
        if self.__args.type not in atom_types:
            Print.stderr("Invalid atom type. Supported types: {}.".format(str_atom_types))
        
    def __get_atom_type(self, atom: 'Atom'):
        return "container" if atom.is_distrobox_container else "chroot"

    def run(self):
        rows = []
        columns = ["AID", "Name", "Distribution", "Created", "Updated"]

        if self.__args.type in ["container", "all"]:
            columns += ["Container Image"]
        
        if self.__args.type == "all":
            columns += ["Type"]
        
        for atom in self.__atoms_backend.atoms.values():
            if self.__args.type == "container" and not atom.is_distrobox_container:
                continue
            elif self.__args.type == "chroot" and atom.is_distrobox_container:
                continue

            _name = atom.name
            _row = [
                atom.short_aid,
                emojify_atom_name(atom),
                atom.distribution.name,
                datetime.datetime.fromisoformat(atom.creation_date).strftime("%Y-%m-%d %H:%M"),
                datetime.datetime.fromisoformat(atom.update_date).strftime("%Y-%m-%d %H:%M"),
            ]

            if self.__args.type in ["container", "all"]:
                if atom.is_distrobox_container:
                    _row += [atom.container_image]
                else:
                    _row += ["n/a"]

            if self.__args.type == "all":
                _row += [self.__get_atom_type(atom)]

            rows.append(_row)

        Print.table(columns, rows, exit=True)
