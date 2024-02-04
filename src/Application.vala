/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Ian Cleary <github@iancleary.me>
 */
 
 public class Tailnet.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.iancleary.Tailnet",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        base.startup();

        var quit_action = new SimpleAction ("quit", null);

        add_action(quit_action);
        set_accels_for_action ("app.quit", {"<Control>q", "<Control>w"});
        quit_action.activate.connect (quit);
    }

    protected override void activate () {
        // First we get the default instances for Granite.Settings and Gtk.Settings
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        // Then, we check if the user's preference is for the dark style and set it if it is
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        // Finally, we listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var main_window = new MainWindow(this);
        main_window.resizable = false;
        main_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
