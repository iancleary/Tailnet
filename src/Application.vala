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
            can_focus = false,
            icon_name = "open-menu",
            tooltip_markup = Granite.markup_accel_tooltip ({"F10"}, "Menu"),
            popover = popover,
            primary = true
        };
        menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var switch_toggle = new Gtk.Switch ();
        switch_toggle.set_margin_top(5);
        switch_toggle.set_margin_bottom(5);

        var headerbar = new Gtk.HeaderBar () {
            show_title_buttons = true
        };
        headerbar.pack_start(switch_toggle);
        headerbar.pack_end (menu_button);


        // Paned layout
        var start_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };
        start_header.add_css_class (Granite.STYLE_CLASS_FLAT);

        var start_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        start_box.append (start_header);

        var end_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };
        end_header.add_css_class (Granite.STYLE_CLASS_FLAT);

        var end_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        end_box.add_css_class (Granite.STYLE_CLASS_VIEW);
        end_box.append (end_header);


        // List of tailscale machines
        var connection_list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

        // setup margin to ensure minimum width (sum of this and button margin)
        connection_list_box.set_margin_start (5);
        connection_list_box.set_margin_end (5);

        string[] connection_list = {"eos-framework", "ephone", "emacos"};
        foreach (string a in connection_list) {
            //  connection_list_box.append(new Gtk.Label(a));
            var connection_button = new Gtk.Button();
            var connection_button_label = new Gtk.Label(a);
            connection_button_label.set_margin_start (25);
            connection_button_label.set_margin_end (25);
            connection_button_label.set_margin_top(5);
            connection_button_label.set_margin_bottom(5);
            
            connection_button.child = connection_button_label;
            connection_button.add_css_class (Granite.STYLE_CLASS_FLAT);
            
            connection_list_box.append(connection_button);
         }

        start_box.append (connection_list_box);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = start_box,
            end_child = end_box,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        var main_window = new Gtk.ApplicationWindow (this) {
            child = paned,
            default_height = 600,
            default_width = 600,
            //  titlebar = new Gtk.Grid () { visible = false },
            titlebar = headerbar,
            title = "Taildock"
        };
        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}