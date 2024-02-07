app_deps = [
    gtk_dep,
    granite_dep
]

app_sources = [
    'Application.vala',
    'MainWindow.vala',
    'CommandLineInterface.vala',
    'Widgets/ReconnectPromptBox.vala'
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    app_sources,
    dependencies: app_deps,
    install : true
)

