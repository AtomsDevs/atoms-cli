import sys

from atoms_cli.utils.print import Print

from atoms_core.utils.distribution import AtomsDistributionsUtils


class ListDistributions:

    __filter_types = {
        "name": "Name",
        "releases": "Releases",
        "architectures": "Architectures"
    }
    __str_filter_types = ", ".join(__filter_types.keys())

    def __init__(self, args: 'argparse.Namespace'):
        self.__args = args
        self.__filters = {}
        self.__validate_args()

    def __validate_args(self):
        if self.__args.filter == "default":
            self.__filters = self.__filter_types
            return

        if len(self.__args.filter) > 0:
            for filter in self.__args.filter.split(","):
                _filter = filter.strip()
                if _filter not in self.__filter_types:
                    Print.stderr("Invalid filter. Supported filters: {}.".format(self.__str_filter_types))
                else:
                    self.__filters[_filter] = self.__filter_types[_filter]

    def run(self):
        results = []
        columns = [column for column in self.__filters.values()]

        for distribution in AtomsDistributionsUtils.get_distributions():
            __result = []

            if "name" in self.__filters:
                __result.append(distribution.name)

            if "releases" in self.__filters:
                __result.append(", ".join(
                    [release for release in distribution.releases]
                ))

            if "architectures" in self.__filters:
                __result.append(", ".join(
                    [architecture for architecture in distribution.architectures.keys()]
                ))

            results.append(__result)

        Print.table(columns=columns, rows=results, exit=True)

        