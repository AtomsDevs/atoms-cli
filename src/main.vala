using Atoms;

private MainLoop loop;
private int exit_status;

int main (string[] args) {
    loop = new MainLoop ();
    var cli = new Cli ();
    cli.run.begin (args, (object, result) => {
        try {
            exit_status = cli.run.end (result);
        } catch (Error error) {
            stderr.printf ("Error: %s\n", error.message);
            exit_status = 1;
        }
        loop.quit ();
    });
    loop.run ();
    return exit_status;
}
