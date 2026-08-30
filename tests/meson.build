test_provider = shared_module(
  'atoms-cli-test-provider',
  'test_provider.vala',
  dependencies: [atoms_core_dep, gio_dep, gee_dep, libpeas_dep]
)

configure_file(
  input: 'atoms-cli-test-provider.plugin',
  output: 'atoms-cli-test-provider.plugin',
  copy: true
)

cli_test = executable(
  'atoms-cli-test',
  'cli_test.vala',
  dependencies: gio_dep
)

cli_test_env = environment()
cli_test_env.set('ATOMS_CLI_TEST_BINARY', atoms_cli.full_path())
cli_test_env.set('ATOMS_CLI_TEST_PROVIDER_PATH', meson.current_build_dir())

test(
  'atoms-cli',
  cli_test,
  env: cli_test_env,
  depends: [atoms_cli, test_provider]
)
