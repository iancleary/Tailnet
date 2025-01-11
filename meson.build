# project name and programming language
project(
    'com.github.iancleary.Tailnet', 'vala', 'c',
    version: '0.0.8',
    license: 'GPL'
)

# Setup Dependenies, used in src/meson.build
gtk_dep = dependency('gtk4', version: '>=4.6.9')
granite_dep = dependency('granite-7', version: '>=7.6.0')
# posix_dep = meson.get_compiler('vala').find_library('posix')

# run 'x'/meson.build files from sub directories
# https://mesonbuild.com/Reference-manual_functions.html#subdir
subdir('po') # translations
subdir('data') # icons
subdir('src') # source code and executable
