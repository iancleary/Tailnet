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
    
        CommandLineInterface cli = new CommandLineInterface();

        // Default to false, but poll CLI during construct, so initial state is never used
        bool is_connected = false;
        
        Gtk.Box start_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        Gtk.Box end_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        Gtk.HeaderBar headerbar = new Gtk.HeaderBar () {
            show_title_buttons = true
        };
        Gtk.Switch switch_toggle = new Gtk.Switch ();
        Gtk.Label connection_status_label = new Gtk.Label("");

        // List of devices or prompt to connect
        Gtk.Box connection_list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

        // Setup parameters for periodic timer
        private int update_period = 10000;  // This could be stored in settings
        private uint delayed_changed_id;

        // extra notifications for debug/development purposes
        private bool debug = true;


        public MainWindow( Tailnet.Application application) {
            Object (application: application);
        }

        public void create_headerbar() {
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
    
            switch_toggle.set_margin_top(5);
            switch_toggle.set_margin_bottom(5);
            headerbar.pack_start(switch_toggle);
            headerbar.pack_start(connection_status_label);
            headerbar.pack_end (menu_button);

             // Connect signal to notifications after initial state is set
             switch_toggle.notify["active"].connect (() => {
                if (switch_toggle.active) {
                    // tailscale up -> ON
                    
                    int status_code = cli.attempt_connection();

                    cli.wait_for_connection_status_to_stabalize();

                    if (debug == true) {
                        string notification_title = "Debug - Connect: " + status_code.to_string() + " " + is_connected.to_string();
                        var notification = new Notification (notification_title);
                        notification.set_body ("`tailscale up` executed successfully!");

                        application.send_notification (null, notification);
                    }

                    if (status_code == 0) {

                        is_connected = true;

                        // Update UI
                        update_body();

                        // Notify
                        send_connection_successful_notification();
                    } 
                    else {
                        // Notify
                        send_connection_failure_notification();
                    }
                    
                    

                } else {
                    // tailscale down -> OFF
                    
                    int status_code = cli.attempt_disconnection();
                    

                    if (debug == true) {
                        string notification_title = "Debug - Disconnect: " + status_code.to_string() + " " + is_connected.to_string();
                        var notification = new Notification (notification_title);
                        notification.set_body ("`tailscale up` executed successfully!");

                        application.send_notification (null, notification);
                    }

                    if (status_code == 0) {

                        is_connected = false;

                        // Update UI
                        update_body();

                        // Notify
                        send_disconnection_successful_notification();
                    } 
                    else {
                        // Notify
                        send_disconnection_failure_notification();
                    }
                }
            });
        }

        public void send_connection_successful_notification() {
            // Prepare Notification of connection
            if (debug == false) {
                var notification = new Notification ("Connected to Tailnet");
                notification.set_body ("`tailscale up` executed successfully!");

                application.send_notification (null, notification);
            }
        }

        public void send_disconnection_successful_notification() {
            // Prepare Notification of disconnect
                    
            if (debug == false) {
                var notification = new Notification ("Disconnected from Tailnet");
                notification.set_body ("`tailscale down` executed successfully!");
                
                application.send_notification (null, notification);
            }
        }

        public void send_connection_failure_notification() {
            // Prepare Notification of connection
            var notification = new Notification ("Failed to connect to Tailnet");
            notification.set_body ("Failed to run `tailscale up`!");

            application.send_notification (null, notification);
        }

        public void send_disconnection_failure_notification() {
            // Prepare Notification of disconnect
                    
            var notification = new Notification ("Failed to disconnect Tailnet");
            notification.set_body ("Failed to run `tailscale down`!");
            
            application.send_notification (null, notification);
        }

        public void update_body() {
            update_connection_list_box();
        }

        public void update_headerbar() {
            // set switch_toggle state so it starts up correctly
            if (is_connected == true) {
                switch_toggle.set_state (true);
            }
            else {
                switch_toggle.set_state (false);
            }
        }

        public void update_connection_list_box() {
            // setup margin to ensure minimum width (sum of this and button margin)
            
            // Remove all children
            Gtk.Widget? first_child = connection_list_box.get_first_child();

            while (first_child != null) {
                connection_list_box.remove(first_child);
                first_child = connection_list_box.get_first_child();
            }

            connection_list_box.set_margin_start (5);
            connection_list_box.set_margin_end (5);
            
            // refresh connection status
            is_connected = cli.get_connection_status ();

            if (is_connected == true) {
                start_box.valign = Gtk.Align.START;
                connection_list_box.margin_bottom = 0;

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
            }
            else {
                start_box.valign = Gtk.Align.CENTER;
                connection_list_box.margin_bottom = 200;

                var power_icon = new Gtk.MenuButton () {
                    can_focus = false,
                    icon_name = "system-shutdown-symbolic",
                    primary = true
                };

                connection_list_box.append(power_icon);

                var disconnected_label = new Gtk.Label(null);
                disconnected_label.set_markup ("<b>Not Connected</b>");
                disconnected_label.set_margin_start (25);
                disconnected_label.set_margin_end (25);
                disconnected_label.set_margin_top(0);
                disconnected_label.set_margin_bottom(0);

                connection_list_box.append(disconnected_label);

                var disconnected_detailed_label_top = new Gtk.Label("Connect again to talk to");
                disconnected_detailed_label_top.set_margin_start (25);
                disconnected_detailed_label_top.set_margin_end (25);
                disconnected_detailed_label_top.set_margin_top(5);
                disconnected_detailed_label_top.set_margin_bottom(0);

                connection_list_box.append(disconnected_detailed_label_top);

                var disconnected_detailed_label_bottom = new Gtk.Label("the other devices in the tailnet.");
                disconnected_detailed_label_bottom.set_margin_start (25);
                disconnected_detailed_label_bottom.set_margin_end (25);
                disconnected_detailed_label_bottom.set_margin_top(0);
                disconnected_detailed_label_bottom.set_margin_bottom(5);
                connection_list_box.append(disconnected_detailed_label_bottom);


                var connect_button = new Gtk.Button();
                var connect_button_label = new Gtk.Label(null);
                connect_button_label.set_markup("<b>Connect</b>");
                connect_button_label.set_margin_start (25);
                connect_button_label.set_margin_end (25);
                connect_button_label.set_margin_top(5);
                connect_button_label.set_margin_bottom(5);

                connect_button.set_margin_start(5);
                connect_button.set_margin_end(5);
                
                connect_button.child = connect_button_label;
                connect_button.add_css_class (Granite.STYLE_CLASS_FLAT);
                connection_list_box.append(connect_button);

                // Button pressed transitions from OFF to ON 
                connect_button.clicked.connect (() => {
                    // tailscale up -> ON
                    // Run command first, then if exit code is 0, proceed to update UI
                    is_connected = true;
                    switch_toggle.set_state(true);
                });

            }
        }

        private void reset_timeout(){
            if(delayed_changed_id > 0)
                Source.remove(delayed_changed_id);
            delayed_changed_id = Timeout.add(update_period, timeout);
        }
        
        private bool timeout(){
            // do actual search here!

            check_status_and_update_if_needed();

            delayed_changed_id = 0;

            return false;
        }

        public void check_status_and_update_if_needed() {

            bool is_connected_status_check = cli.get_connection_status();

            if (is_connected != is_connected_status_check) {
                is_connected = is_connected_status_check;
                
                // These will update UI and send notifications as needed
                update_headerbar();
                update_body();
            }

            reset_timeout();
        }
    
        construct {
            title = "Tailnet";
            icon_name = "com.github.iancleary.Tailnet";

            // Check initial state of tailscale up/down
            is_connected = cli.get_connection_status ();
            
            // src/CommandLineInterface.vala
            // wrapper around tailscale CLI
            //  var cli = new CommandLineInterface();
    
            
        
            // Create Layout of MainWindow
            // initialize UI for headerbar
            create_headerbar();

            // Assign as ApplicationWindow.titlebar
            titlebar = headerbar;
             
            // Update headerbar widgets according to `is_connected`
            update_headerbar();

            // Update based upon tailscale status
            update_connection_list_box();

            // Add connection_list_box to left pane
            start_box.append (connection_list_box);

            // Setup Paned Layout Widget
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
                start_child = start_box,
                end_child = end_box,
                resize_start_child = false,
                shrink_end_child = false,
                shrink_start_child = false,
            };

            // Assign as ApplicationWIndow.child
            child = paned;

            // Set Up Initial Dimensions
            default_width = 600;
            default_height = 600;
            
            // debug specific settings

            if (debug == true) {
                update_period = 2000; // 2 seconds
            }

            // setup periodic check of tailscale connection
            timeout();
        }

        //  Connection[] update_start_pane(bool is_connected) {
        //      return cli.get_devices();
            
        //  }
    }
}

