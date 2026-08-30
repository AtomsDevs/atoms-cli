using Gee;

namespace Atoms {

    public class CliTestProvider : Object, Provider {
        public string id { owned get { return "test"; } }
        public string name { owned get { return "Test"; } }
        public uint abi_version { get { return PROVIDER_ABI; } }
        public bool available { get { return true; } }
        public string unavailable_reason { owned get { return ""; } }

        public async ArrayList<Distribution> list_distributions (
            Cancellable? cancellable = null
        ) throws Error {
            var values = new ArrayList<Distribution> ();
            values.add (new Distribution (
                id,
                "example.test/project/distribution",
                "Example",
                "1",
                "Example distribution",
                "example.test/project/distribution"
            ));
            return values;
        }

        public async ArrayList<Environment> list_environments (
            Cancellable? cancellable = null
        ) throws Error {
            var values = new ArrayList<Environment> ();
            values.add (environment ());
            return values;
        }

        public async Environment create_environment (
            Distribution distribution,
            string name,
            Cancellable? cancellable = null
        ) throws Error {
            return new Environment (
                id,
                "created",
                name,
                distribution.version,
                distribution.origin
            );
        }

        public string[] shell_argv (Environment environment,
                                    string command,
                                    string[] arguments) throws Error {
            string[] argv = new string[arguments.length + 1];
            argv[0] = command;
            for (int i = 0; i < arguments.length; i++)
                argv[i + 1] = arguments[i];
            return argv;
        }

        public async Environment update_policy (
            Environment environment,
            Cancellable? cancellable = null
        ) throws Error {
            return environment;
        }

        public async ArrayList<ProcessInfo> list_processes (
            Environment environment,
            Cancellable? cancellable = null
        ) throws Error {
            var values = new ArrayList<ProcessInfo> ();
            values.add (new ProcessInfo (42, "/bin/bash", 1.5, 2 * 1024 * 1024));
            return values;
        }

        public async string[] list_signals (
            Cancellable? cancellable = null
        ) throws Error {
            return { "TERM", "KILL" };
        }

        public async void signal_process (
            Environment environment,
            int pid,
            string signal_name,
            Cancellable? cancellable = null
        ) throws Error {
        }

        public async void stop_environment (
            Environment environment,
            Cancellable? cancellable = null
        ) throws Error {
        }

        public async void delete_environment (
            Environment environment,
            Cancellable? cancellable = null
        ) throws Error {
        }

        private Environment environment () {
            return new Environment (
                id,
                "environment-test",
                "Example environment",
                "1",
                "example.test/project/distribution"
            );
        }
    }
}

[CCode (cname = "peas_register_types")]
public void register_types (Peas.ObjectModule module) {
    module.register_extension_type (
        typeof (Atoms.Provider),
        typeof (Atoms.CliTestProvider)
    );
}
