atoms_cli = executable(
  'atoms-cli',
  ['cli.vala', 'main.vala'],
  dependencies: [atoms_core_dep, gio_dep, gee_dep, libpeas_dep, posix_dep],
  install: true,
  install_rpath: get_option('prefix') / get_option('libdir')
)
