/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Ian Cleary <github@iancleary.me>
 */
 
 public class MyApp : Gtk.Application {
    public MyApp () {
        Object (
            application_id: "com.github.iancleary.Taildock",
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

        var quit_button = new Gtk.Button () {
            action_name = "app.quit",
            child = new Granite.AccelLabel.from_action_name ("Quit", "app.quit")
        };
        quit_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var popover = new Gtk.Popover () {
            child = quit_button
        };
        popover.add_css_class (Granite.STYLE_CLASS_MENU);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu",
            tooltip_markup = Granite.markup_accel_tooltip ({"F10"}, "Menu"),
            popover = popover,
            primary = true
        };
        menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var headerbar = new Gtk.HeaderBar () {
            show_title_buttons = true
        };
        headerbar.pack_end (menu_button);
    
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Taildock",
            titlebar = headerbar
        };
        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}