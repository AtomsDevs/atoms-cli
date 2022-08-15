import sys
from enum import Enum

from atoms_core.utils.distribution import AtomsDistributionsUtils

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

    @property
    def atom_type(self) -> 'AtomType':
        return atom_types[self.__args.type]

    def run(self):
        if self.__args.type == "chroot":
            distribution = AtomsDistributionsUtils.get_distribution(self.__args.distribution)
            
            if distribution.name == "unknown":
                Print.stderr("Unknown distribution: {}".format(self.__args.distribution))
                sys.exit(1)
            
            if self.__args.release not in distribution.releases:
                Print.stderr("Unknown release: {}".format(self.__args.release))
                sys.exit(1)

            if self.__args.arch not in distribution.architectures:
                Print.stderr("Unknown architecture: {}".format(self.__args.arch))
                sys.exit(1)

            atom = self.__atoms_backend.request_new_atom(
                name=self.__args.name,
                atom_type=self.atom_type,
                distribution=distribution,
                architecture=self.__args.arch,
                release=self.__args.release,
                config_fn=self.__config_fn,
                unpack_fn=self.__unpack_fn,
                finalizing_fn=self.__finalizing_fn,
                error_fn=self.__error_fn
            )
        elif self.__args_type == "container":
            atom = self.__atoms_backend.request_new_atom(
                name=self.__args.name,
                atom_type=self.atom_type,
                container_image=self.__args.container_image,
                distrobox_fn=self.__unpack_fn,
                finalizing_fn=self.__finalizing_fn,
                error_fn=self.__error_fn
            )
        else:
            Print.stderr("Invalid atom type. Supported types: {}.".format(str_atom_types))
            sys.exit(1)

        if atom:
            Print.stdout("⚛️ New atom created: {} ({}).".format(atom.name, atom.aid))
    
    def __config_fn(self, status: int):
        if status == 0:
            Print.stdout("🔧 Configuring new atom...", new_line=False)
        elif status == 1:
            Print.stdout("Done.")

    def __unpack_fn(self, status: int):
        if status == 0:
            Print.stdout("🗳️ Unpacking image...", new_line=False)
        elif status == 1:
            Print.stdout("Done.")

    def __finalizing_fn(self, status: int):
        if status == 0:
            Print.stdout("🪄 Finalizing...", new_line=False)
        elif status == 1:
            Print.stdout("Done.")

    def __error_fn(self, status: int):
        Print.stderr("Error {}".format(status))
