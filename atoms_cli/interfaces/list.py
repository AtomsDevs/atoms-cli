import sys

from atoms_cli.utils.print import Print
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
        columns = ["Name", "Distribution", "Created", "Updated"]

        if self.__args.type in ["container", "all"]:
            columns += ["Container ID", "Container Image"]
        
        if self.__args.type == "all":
            columns += ["Type"]
        
        for atom in self.__atoms_backend.atoms.values():
            if self.__args.type == "container" and not atom.is_distrobox_container:
                continue
            
            _row = [
                atom.name, 
                atom.distribution.name,
                atom.creation_date, 
                atom.update_date
            ]

            if self.__args.type in ["container", "all"]:
                if atom.is_distrobox_container:
                    _row += [
                        atom.container_id, 
                        atom.container_image
                    ]
                else:
                    _row += ["n/a", "n/a"]

            if self.__args.type == "all":
                _row += [self.__get_atom_type(atom)]

            rows.append(_row)

        Print.table(columns, rows, exit=True)

