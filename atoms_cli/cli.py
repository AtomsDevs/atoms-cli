import os
import sys
import argparse

from atoms_core.atoms import AtomsBackend

from atoms_cli.interfaces.distributions import ListDistributions
from atoms_cli.interfaces.list import ListAtom
from atoms_cli.interfaces.create import CreateAtom


class AtomsCLI:

    def __init__(self):
        self.__atoms_backend = AtomsBackend()
        self.__parser = argparse.ArgumentParser(description='Atoms CLI')
        subparsers = self.__parser.add_subparsers(dest='command', help='sub-command help')

        list_parser = subparsers.add_parser('distributions', help='list supported distributions')
        list_parser.add_argument('-f', '--filter', help='choose which records should be displayed', default='default')

        list_parser = subparsers.add_parser('list', help='list all your atoms')
        list_parser.add_argument('-t', '--type', help='type of atoms to list', default='all')

        create_parser = subparsers.add_parser('create', help='create a new atom')
        create_parser.add_argument('-t', '--type', help='type of atom to create', default='chroot')
        create_parser.add_argument('-n', '--name', help='name of atom to create')
        create_parser.add_argument('-i', '--image', help='image of atom to create')
        create_parser.add_argument('-d', '--distribution', help='distribution of choice')
        create_parser.add_argument('-r', '--release', help='distribution release')
        create_parser.add_argument('-a', '--arch', help='distribution architecture')
        
        self.__args = self.__parser.parse_args()

    def run(self):
        if self.__args.command == 'distributions':
            ListDistributions(self.__args).run()
        elif self.__args.command == 'list':
            ListAtom(self.__atoms_backend, self.__args).run()
        elif self.__args.command == 'create':
            CreateAtom(self.__atoms_backend, self.__args).run()
        else:
            self.__parser.print_help()
            sys.exit(1)


def main():
    AtomsCLI().run()
