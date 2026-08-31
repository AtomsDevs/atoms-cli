using Gee;

namespace Atoms {

    private errordomain CliError {
        INVALID_ARGUMENT,
        AMBIGUOUS
    }

    private class Arguments : Object {
        public string provider_id { get; private set; default = ""; }
        public ArrayList<string> values { get; private set; }

        public Arguments (string[] args) throws Error {
            values = new ArrayList<string> ();
            bool literal = false;
            for (int i = 2; i < args.length; i++) {
                if (!literal && args[i] == "--") {
                    literal = true;
                    continue;
                }
                if (!literal && args[i] == "--provider") {
                    if (++i >= args.length)
                        throw new CliError.INVALID_ARGUMENT ("--provider requires an id");
                    provider_id = args[i];
                    continue;
                }
                values.add (args[i]);
            }
        }
    }

    private class DistributionSelection : Object {
        public Provider provider { get; construct; }
        public Distribution distribution { get; construct; }

        public DistributionSelection (Provider provider,
                                      Distribution distribution) {
            Object (provider: provider, distribution: distribution);
        }
    }

    private class EnvironmentSelection : Object {
        public Provider provider { get; construct; }
        public Environment environment { get; construct; }

        public EnvironmentSelection (Provider provider,
                                     Environment environment) {
            Object (provider: provider, environment: environment);
        }
    }

    public class Cli : Object {
        private ProviderRegistry registry;

        public Cli (string[]? provider_paths = null) {
            registry = new ProviderRegistry (provider_paths);
            registry.load ();
        }

        public async int run (string[] args) throws Error {
            if (args.length < 2) {
                print_help ();
                return 1;
            }

            var parsed = new Arguments (args);
            switch (args[1]) {
                case "providers":
                    require_count (parsed, 0, "providers");
                    print_providers ();
                    return 0;
                case "distributions":
                    require_count (parsed, 0, "distributions");
                    yield print_distributions (parsed.provider_id);
                    return 0;
                case "list":
                    require_count (parsed, 0, "list");
                    yield print_environments (parsed.provider_id);
                    return 0;
                case "create":
                    require_count (parsed, 2, "create <distribution> <name>");
                    yield create_environment (
                        parsed.values[0],
                        parsed.values[1],
                        parsed.provider_id
                    );
                    return 0;
                case "enter":
                    require_count (parsed, 1, "enter <environment>");
                    yield execute_environment (
                        parsed.values[0],
                        "/bin/bash",
                        { "-i" },
                        parsed.provider_id
                    );
                    return 0;
                case "exec":
                    if (parsed.values.size < 2)
                        throw usage_error ("exec <environment> -- <command> [arguments]");
                    string[] command_arguments = new string[parsed.values.size - 2];
                    for (int i = 2; i < parsed.values.size; i++)
                        command_arguments[i - 2] = parsed.values[i];
                    yield execute_environment (
                        parsed.values[0],
                        parsed.values[1],
                        command_arguments,
                        parsed.provider_id
                    );
                    return 0;
                case "processes":
                    require_count (parsed, 1, "processes <environment>");
                    yield print_processes (parsed.values[0], parsed.provider_id);
                    return 0;
                case "update":
                    require_count (parsed, 1, "update <environment>");
                    yield update_environment (parsed.values[0], parsed.provider_id);
                    return 0;
                case "update-all":
                    require_count (parsed, 0, "update-all");
                    yield update_all (parsed.provider_id);
                    return 0;
                case "applications":
                    require_count (parsed, 1, "applications <environment>");
                    yield print_applications (parsed.values[0], parsed.provider_id);
                    return 0;
                case "export":
                    require_count (parsed, 2, "export <environment> <application>");
                    yield set_application_exported (
                        parsed.values[0],
                        parsed.values[1],
                        true,
                        parsed.provider_id
                    );
                    return 0;
                case "unexport":
                    require_count (parsed, 2, "unexport <environment> <application>");
                    yield set_application_exported (
                        parsed.values[0],
                        parsed.values[1],
                        false,
                        parsed.provider_id
                    );
                    return 0;
                case "signal":
                    require_count (parsed, 3, "signal <environment> <pid> <signal>");
                    int pid;
                    if (!int.try_parse (parsed.values[1], out pid) || pid <= 0)
                        throw new CliError.INVALID_ARGUMENT ("pid must be positive");
                    yield signal_process (
                        parsed.values[0],
                        pid,
                        parsed.values[2],
                        parsed.provider_id
                    );
                    return 0;
                case "stop":
                    require_count (parsed, 1, "stop <environment>");
                    yield stop_environment (parsed.values[0], parsed.provider_id);
                    return 0;
                case "delete":
                    require_count (parsed, 1, "delete <environment>");
                    yield delete_environment (parsed.values[0], parsed.provider_id);
                    return 0;
                case "help":
                case "--help":
                case "-h":
                    print_help ();
                    return 0;
                default:
                    throw new CliError.INVALID_ARGUMENT (
                        "unknown command: %s".printf (args[1])
                    );
            }
        }

        private void print_providers () {
            stdout.printf ("ID\tNAME\tAVAILABLE\n");
            foreach (var provider in registry.providers)
                stdout.printf (
                    "%s\t%s\t%s\n",
                    provider.id,
                    provider.name,
                    provider.available ? "yes" : "no"
                );
            foreach (var diagnostic in registry.diagnostics)
                stderr.printf ("Provider: %s\n", diagnostic);
        }

        private async void print_distributions (string provider_id) throws Error {
            stdout.printf ("PROVIDER\tID\tNAME\tVERSION\tORIGIN\n");
            foreach (var provider in providers (provider_id)) {
                var distributions = yield provider.list_distributions ();
                foreach (var distribution in distributions)
                    stdout.printf (
                        "%s\t%s\t%s\t%s\t%s\n",
                        provider.id,
                        distribution.id,
                        distribution.name,
                        distribution.version,
                        distribution.origin
                    );
            }
        }

        private async void print_environments (string provider_id) throws Error {
            stdout.printf ("PROVIDER\tID\tNAME\tVERSION\tORIGIN\n");
            foreach (var provider in providers (provider_id)) {
                var environments = yield provider.list_environments ();
                foreach (var environment in environments)
                    stdout.printf (
                        "%s\t%s\t%s\t%s\t%s\n",
                        provider.id,
                        environment.id,
                        environment.name,
                        environment.version,
                        environment.origin
                    );
            }
        }

        private async void create_environment (string selector,
                                               string name,
                                               string provider_id) throws Error {
            var selected = yield find_distribution (selector, provider_id);
            var environment = yield selected.provider.create_environment (
                selected.distribution,
                name
            );
            stdout.printf ("%s\t%s\n", environment.id, environment.name);
        }

        private async void execute_environment (string selector,
                                                string command,
                                                string[] arguments,
                                                string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            string[] argv = selected.provider.shell_argv (
                selected.environment,
                command,
                arguments,
                command == "/bin/bash" && "-i" in arguments
            );
            Posix.execvp (argv[0], argv);
            throw new CoreError.PROVIDER_FAILED (
                "could not execute environment command: %s".printf (Posix.strerror (Posix.errno))
            );
        }

        private async void print_processes (string selector,
                                            string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            var processes = yield selected.provider.list_processes (selected.environment);
            stdout.printf ("PID\tCPU\tMEMORY\tCOMMAND\n");
            foreach (var process in processes)
                stdout.printf (
                    "%d\t%s\t%s\t%s\n",
                    process.pid,
                    process.cpu_label (),
                    process.memory_label (),
                    process.command
                );
        }

        private async void update_environment (string selector,
                                               string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            run_update (selected.provider.update_argv (selected.environment));
        }

        private async void update_all (string provider_id) throws Error {
            foreach (var provider in providers (provider_id)) {
                var environments = yield provider.list_environments ();
                foreach (var environment in environments) {
                    stdout.printf ("Updating %s\n", environment.display_name ());
                    stdout.flush ();
                    run_update (provider.update_argv (environment));
                }
            }
        }

        private void run_update (string[] argv) throws Error {
            var launcher = new SubprocessLauncher (SubprocessFlags.STDIN_INHERIT);
            var process = launcher.spawnv (argv);
            process.wait_check ();
        }

        private async void print_applications (string selector,
                                               string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            var applications = yield selected.provider.list_applications (
                selected.environment
            );
            stdout.printf ("EXPORTED\tNAME\tID\n");
            foreach (var application in applications)
                stdout.printf (
                    "%s\t%s\t%s\n",
                    application.exported ? "yes" : "no",
                    application.name,
                    application.id
                );
        }

        private async void set_application_exported (string selector,
                                                     string application_id,
                                                     bool exported,
                                                     string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            var applications = yield selected.provider.list_applications (
                selected.environment
            );
            foreach (var application in applications) {
                if (application.id != application_id)
                    continue;
                yield selected.provider.set_application_exported (
                    selected.environment,
                    application,
                    exported
                );
                return;
            }
            throw new CoreError.NOT_FOUND (
                "application not found: %s".printf (application_id)
            );
        }

        private async void signal_process (string selector,
                                           int pid,
                                           string signal_name,
                                           string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            yield selected.provider.signal_process (
                selected.environment,
                pid,
                signal_name
            );
        }

        private async void stop_environment (string selector,
                                             string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            yield selected.provider.stop_environment (selected.environment);
        }

        private async void delete_environment (string selector,
                                               string provider_id) throws Error {
            var selected = yield find_environment (selector, provider_id);
            yield selected.provider.delete_environment (selected.environment);
        }

        private async DistributionSelection find_distribution (
            string selector,
            string provider_id
        ) throws Error {
            DistributionSelection? selected = null;
            foreach (var provider in providers (provider_id)) {
                var distributions = yield provider.list_distributions ();
                foreach (var distribution in distributions) {
                    if (distribution.id != selector &&
                        distribution.origin != selector &&
                        distribution.name.ascii_down () != selector.ascii_down ())
                        continue;
                    if (selected != null)
                        throw new CliError.AMBIGUOUS (
                            "distribution matches more than one provider; use --provider"
                        );
                    selected = new DistributionSelection (provider, distribution);
                }
            }
            if (selected == null)
                throw new CoreError.NOT_FOUND ("distribution not found: %s".printf (selector));
            return selected;
        }

        private async EnvironmentSelection find_environment (
            string selector,
            string provider_id
        ) throws Error {
            EnvironmentSelection? selected = null;
            foreach (var provider in providers (provider_id)) {
                var environments = yield provider.list_environments ();
                foreach (var environment in environments) {
                    if (environment.id != selector &&
                        !environment.id.has_prefix (selector) &&
                        environment.name != selector)
                        continue;
                    if (selected != null)
                        throw new CliError.AMBIGUOUS (
                            "environment matches more than once; use a complete id"
                        );
                    selected = new EnvironmentSelection (provider, environment);
                }
            }
            if (selected == null)
                throw new CoreError.NOT_FOUND ("environment not found: %s".printf (selector));
            return selected;
        }

        private ArrayList<Provider> providers (string provider_id) throws Error {
            var selected = new ArrayList<Provider> ();
            if (provider_id != "") {
                selected.add (registry.require (provider_id));
                return selected;
            }
            foreach (var provider in registry.providers) {
                if (provider.available)
                    selected.add (provider);
            }
            if (selected.size == 0)
                throw new CoreError.NOT_AVAILABLE ("no Atoms provider is available");
            return selected;
        }

        private static void require_count (Arguments args,
                                           int count,
                                           string usage) throws Error {
            if (args.values.size != count)
                throw usage_error (usage);
        }

        private static CliError usage_error (string usage) {
            return new CliError.INVALID_ARGUMENT ("usage: atoms-cli %s".printf (usage));
        }

        private static void print_help () {
            stdout.printf (
                "Usage: atoms-cli <command> [--provider id]\n\n" +
                "Commands:\n" +
                "  providers\n" +
                "  distributions\n" +
                "  list\n" +
                "  create <distribution> <name>\n" +
                "  enter <environment>\n" +
                "  exec <environment> -- <command> [arguments]\n" +
                "  processes <environment>\n" +
                "  update <environment>\n" +
                "  update-all\n" +
                "  applications <environment>\n" +
                "  export <environment> <application>\n" +
                "  unexport <environment> <application>\n" +
                "  signal <environment> <pid> <signal>\n" +
                "  stop <environment>\n" +
                "  delete <environment>\n"
            );
        }
    }
}
