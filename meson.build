project(
  'atoms-cli',
  ['vala', 'c'],
  version: '2.0.0',
  meson_version: '>= 1.3.0',
  default_options: ['warning_level=2', 'werror=false']
)

atoms_core_dep = dependency('atoms-core-2', version: '>= 2.0.0')
gio_dep = dependency('gio-2.0')
gee_dep = dependency('gee-0.8')
libpeas_dep = dependency('libpeas-2', version: '>= 2.0')
posix_dep = meson.get_compiler('vala').find_library('posix')

subdir('src')
subdir('tests')
