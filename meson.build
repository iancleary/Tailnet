# project name and programming language
project(
    'com.github.iancleary.Tailnet', 'vala', 'c',
    version: '0.0.1',
    license: 'GPL'
)

# Setup Dependenies, used in src/meson.build
gtk_dep = dependency('gtk4')
granite_dep = dependency('granite-7')

# run 'x'/meson.build files from sub directories
# https://mesonbuild.com/Reference-manual_functions.html#subdir
subdir('po') # translations
subdir('data') # icons
subdir('src') # source code and executable
