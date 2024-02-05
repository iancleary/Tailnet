/*
* Copyright (c) 2024-Present Ian Cleary (https://iancleary.me)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License version 3, as published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Tailnet {
    public class MainWindow: Gtk.ApplicationWindow {
    
        public MainWindow( Tailnet.Application application) {
            Object (application: application);
        }
    
        construct {
            title = "Tailnet";
            icon_name = "com.github.iancleary.Tailnet";

            // src/CommandLineInterface.vala
            // wrapper around tailscale CLI
            var cli = new CommandLineInterface();
    
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

            // Check state of tailscale...set switch_toggle state so it starts up correctly


            // Connect signal to notifications after initial state is set
            switch_toggle.notify["active"].connect (() => {
                if (switch_toggle.active) {
                    var notification = new Notification ("The switch is on");
                    notification.set_body ("This is my tailscale up notification!");

                    application.send_notification (null, notification);
                } else {
                    var notification = new Notification ("The switch is off");
                    notification.set_body ("This is my tailscale down notification!");
                    application.send_notification (null, notification);
                }
            });
    
            var headerbar = new Gtk.HeaderBar () {
                show_title_buttons = true
            };
            headerbar.pack_start(switch_toggle);
            headerbar.pack_end (menu_button);
    
    
            titlebar = headerbar;

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

            Connection[] connection_list = cli.get_devices();
            foreach (Connection device in connection_list) {
                //  connection_list_box.append(new Gtk.Label(a));
                var connection_button = new Gtk.Button();
                var connection_button_label = new Gtk.Label(device.name);
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
                shrink_start_child = false,
            };
            
            child = paned;
            default_width = 600;
            default_height = 600;
            titlebar = headerbar;
    
        }
    }
}

