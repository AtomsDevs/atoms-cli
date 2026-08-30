private string cli_path;
private string provider_path;

private string run (string[] arguments) {
    string[] argv = new string[arguments.length + 1];
    argv[0] = cli_path;
    for (int i = 0; i < arguments.length; i++)
        argv[i + 1] = arguments[i];

    var launcher = new SubprocessLauncher (
        SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE
    );
    launcher.setenv ("ATOMS_PROVIDER_PATH", provider_path, true);
    try {
        var process = launcher.spawnv (argv);
        string? output;
        string? errors;
        process.communicate_utf8 (null, null, out output, out errors);
        assert_true (process.get_successful ());
        assert_true (errors == "");
        return output ?? "";
    } catch (Error error) {
        assert_not_reached ();
    }
}

private void test_commands () {
    assert_true (run ({ "providers" }).contains ("test\tTest\tyes"));
    assert_true (run ({ "distributions" }).contains ("Example\t1"));
    assert_true (run ({ "list" }).contains ("environment-test"));
    assert_true (run ({ "create", "Example", "Created environment" }).contains (
        "created\tCreated environment"
    ));
    assert_true (run ({ "processes", "environment-test" }).contains (
        "42\t1.5%\t2.0 MiB\t/bin/bash"
    ));
    assert_true (run ({ "signal", "environment-test", "42", "TERM" }) == "");
    assert_true (run ({ "stop", "environment-test" }) == "");
    assert_true (run ({ "delete", "environment-test" }) == "");
    assert_true (run ({
        "exec",
        "environment-test",
        "--",
        "/usr/bin/printf",
        "cli-exec"
    }) == "cli-exec");
}

int main (string[] args) {
    Test.init (ref args);
    cli_path = GLib.Environment.get_variable ("ATOMS_CLI_TEST_BINARY");
    provider_path = GLib.Environment.get_variable ("ATOMS_CLI_TEST_PROVIDER_PATH");
    Test.add_func ("/atoms/cli/commands", test_commands);
    return Test.run ();
}
