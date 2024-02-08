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
    
        CommandLineInterface cli;

        // Default to false, but poll CLI during construct, so initial state is never used
        private bool is_connected;
        // bool to track UI state to connection state
        private bool content_grid_state;

        // Setup parameters for periodic timer
        private int update_period;
        private uint delayed_changed_id;

        // extra notifications for debug/development purposes
        private bool debug;
        // List of devices in tailnet
        private Connection[] connection_list;

        // Main UI Box to store wheter the UI shows the connection list/pane or reconnect prompt box
        private Gtk.Grid content_grid;
        
        // List of devices or prompt to connect
        private Gtk.Box connection_list_box;
        private Gtk.Box info_box;
        private Connection selected_device;
        
        //  Gtk.Box reconnect_prompt_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        private Gtk.Box reconnect_prompt_box;
        
        // titlebar
        private Gtk.HeaderBar headerbar;
        private Gtk.Switch switch_toggle;
        private Gtk.Label connection_status_label;


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

            connect_switch_toggle_signal();
        }

        public void connect_switch_toggle_signal() {
             // Connect signal to notifications after initial state is set
             switch_toggle.notify["active"].connect (() => {
                if (switch_toggle.active) {
                    // tailscale up -> ON
                    
                    Command connect_command = cli.attempt_connection();

                    cli.wait_for_connection_status_to_stabalize();

                    if (debug == true) {
                        string notification_title = "Debug - Connect: " + connect_command.status.to_string() + " " + is_connected.to_string();
                        var notification = new Notification (notification_title);
                        notification.set_body ("`tailscale up` executed successfully!");

                        application.send_notification (null, notification);
                    }

                    if (connect_command.status == 0) {

                        // Update state variables
                        is_connected = true;
                        connection_list = cli.get_devices();

                        // Update UI
                        update_content_grid();
                        update_connection_list_box();

                        // Notify
                        send_connection_successful_notification();
                    } 
                    else {
                        // Notify
                        send_connection_failure_notification();
                    }
                    
                    

                } else {
                    // tailscale down -> OFF
                    
                    Command disconnect_command = cli.attempt_disconnection();
                    

                    if (debug == true) {
                        string notification_title = "Debug - Disconnect: " + disconnect_command.status.to_string() + " " + is_connected.to_string();
                        var notification = new Notification (notification_title);
                        notification.set_body ("`tailscale up` executed successfully!");

                        application.send_notification (null, notification);
                    }

                    if (disconnect_command.status == 0) {

                        is_connected = false;

                        // Update UI
                        update_content_grid();

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

        public void update_headerbar() {
            // set switch_toggle state so it starts up correctly
            if (is_connected == true) {
                switch_toggle.set_state (true);
            }
            else {
                switch_toggle.set_state (false);
            }
        }

        public void reconnect() {
            // tailscale up -> ON
            // Run command first, then if exit code is 0, proceed to update UI
            is_connected = true;
            switch_toggle.set_state(true);
        }

        public void update_content_grid() {
            
            //  Empty Child
            Gtk.Widget? first_child = content_grid.get_first_child();

            while (first_child != null) {
                content_grid.remove(first_child);
                first_child = content_grid.get_first_child();
            }

            if (is_connected == false) {
                content_grid_state = false;
                
                content_grid.valign = Gtk.Align.CENTER;
                content_grid.halign = Gtk.Align.CENTER;
                content_grid.set_hexpand(true);

                content_grid.attach(reconnect_prompt_box, 1, 1, 1, 1);
            }
            else {
                content_grid_state = true;
                
                content_grid.valign = Gtk.Align.FILL;
                content_grid.halign = Gtk.Align.FILL;

                Gtk.Separator vr = new Gtk.Separator(Gtk.Orientation.VERTICAL);
                vr.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);

                content_grid.attach(connection_list_box, 0, 0, 1, 1);
                content_grid.attach(vr, 1, 0, 1, 1);
                content_grid.attach(info_box, 2, 0, 1, 1);
                
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

            connection_list_box.set_margin_bottom(0);

            connection_list = cli.get_devices();
            for(int i = 0; i<connection_list.length; i++) {
                Connection device = connection_list[i];

                Gtk.Button connection_button = new Gtk.Button();

                var connection_name_label = new Gtk.Label(null);
                connection_name_label.set_markup ("<b>"+device.name + "</b>");

                var connection_status_icon = new Gtk.MenuButton() {
                    can_focus = false,
                    primary = true
                };

                if (device.status == "online") {
                    // Green Dot
                    connection_status_icon.set_icon_name("user-available");
                }
                else {
                    // Gray Dot
                    connection_status_icon.set_icon_name("user-offline");
                }

                Gtk.Box connection_label_top_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
                connection_label_top_row.append(connection_status_icon);
                connection_label_top_row.append(connection_name_label);
                connection_label_top_row.set_margin_start(25);
                connection_label_top_row.set_margin_end(25);
                connection_label_top_row.halign = Gtk.Align.START;


                Gtk.Label connection_label_bottom_row = new Gtk.Label(device.ipv4_address);
                connection_label_bottom_row.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);
                connection_label_bottom_row.halign = Gtk.Align.START;
                connection_label_bottom_row.set_margin_start (35);
                connection_label_bottom_row.set_margin_end(25);

                Gtk.Box connection_label_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
                connection_label_box.append(connection_label_top_row);
                connection_label_box.append(connection_label_bottom_row);

                connection_label_box.set_margin_top(0);
                connection_label_box.set_margin_bottom(0);

                connection_button.set_child(connection_label_box);
                connection_button.add_css_class (Granite.STYLE_CLASS_FLAT);

                connection_button.clicked.connect(() => {
                    selected_device = device;
                    update_info_box();
                });

                connection_list_box.append(connection_button);

                // If not the last index, append hr
                if (i < connection_list.length - 1 ) {
                    // Add horizontal rule separator between children
                    Gtk.Separator hr = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
                    hr.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);
                    hr.set_margin_top(5);
                    connection_list_box.append(hr);
                }
            }   
        }

        public void update_info_box() {
            // setup margin to ensure minimum width (sum of this and button margin)
            
            // Remove all children
            Gtk.Widget? first_child = info_box.get_first_child();

            while (first_child != null) {
                info_box.remove(first_child);
                first_child = info_box.get_first_child();
            }

            // get device information
            Connection ip_addresses = cli.get_device_ip(selected_device.name);

            var addresses_label = new Gtk.Label(null);
            addresses_label.set_markup ("<b>Tailscale Addresses</b>");
            addresses_label.set_hexpand(true);
            addresses_label.set_vexpand(true);


            info_box.append(addresses_label);


            var ipv4_address_label = new Gtk.Label(ip_addresses.ipv4_address);
            var ipv6_address_label = new Gtk.Label(ip_addresses.ipv6_address);

            ipv4_address_label.set_hexpand(true);
            ipv6_address_label.set_hexpand(true);
            ipv4_address_label.set_vexpand(true);
            ipv6_address_label.set_vexpand(true);
            ipv4_address_label.halign = Gtk.Align.FILL;
            ipv6_address_label.halign = Gtk.Align.FILL;

            // Add horizontal rule separator between children
            
            Gtk.Label[] ip_address_labels = {ipv4_address_label, ipv6_address_label};

            foreach(Gtk.Label label in ip_address_labels) {
                Gtk.Separator hr = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
                hr.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);
                hr.set_margin_top(5);

                hr.set_hexpand(true);
                hr.halign = Gtk.Align.CENTER;
                hr.set_vexpand(true);

                info_box.append(hr);
                info_box.append(label);
            }
        }

        private void reset_state() {
            // Update both state variables, since UI update methods are not called
            is_connected = cli.get_connection_status();
            connection_list = cli.get_devices();
            update_connection_list_box();
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
                reset_state();
                reset_timeout();
                return;
            }

            // Deeper inspection of connection list
            Connection[] connection_list_check = cli.get_devices();
            bool update_required = false;

            if (connection_list.length != connection_list_check.length) {
                reset_state();
                reset_timeout();
                return;
            }
            else {
                for (int i = 0; i < connection_list.length; i++) {
                    Connection existing_device = connection_list[i];
                    Connection check_device = connection_list_check[i];
    
                    if (existing_device.ipv4_address != check_device.ipv4_address) {
                        update_required = true;
                    }
    
                //      if (existing_device.name != check_device.name) {
                //          update_required = true;
                //      }
    
                //      if (existing_device.status != check_device.status) {
                //          update_required = true;
                //      }
    
                }
            }

            if (update_required == true) {
                // These will update UI and send notifications as needed
                reset_state();
                reset_timeout();
                return;
            }

            // Catch All Reset
            reset_timeout();
        }
    
        construct {
            title = "Tailnet";
            icon_name = "com.github.iancleary.Tailnet";

            cli = new CommandLineInterface();

            // Check initial state of tailscale up/down
            is_connected = cli.get_connection_status ();
            
            // Ensure initial states match
            content_grid_state = is_connected;

            // to store wheter the UI shows the connection list/pane or reconnect prompt box
            content_grid = new Gtk.Grid () {
                column_spacing = 6,
                row_spacing = 6,
            };
            
            // List of devices or prompt to connect
            connection_list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);            
            connection_list_box.set_vexpand(true);

            info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            info_box.valign = Gtk.Align.CENTER;
            info_box.halign = Gtk.Align.CENTER;
            info_box.set_hexpand(true);
            info_box.set_vexpand(true);

            //  info_box.add_css_class(Granite.STYLE_CLASS_VIEW);
            
            // prompt to show that you are not connected and prompt a reconnection
            reconnect_prompt_box = new ReconnectPromptBox(this);

            content_grid.halign = Gtk.Align.FILL;
            content_grid.valign = Gtk.Align.FILL;
            content_grid.set_vexpand(true);
            content_grid.set_hexpand(true);
            content_grid.add_css_class(Granite.STYLE_CLASS_FLAT);

            //  add_css_class(Granite.STYLE_CLASS_CHECKERBOARD);
            // titlebar
            headerbar = new Gtk.HeaderBar () {
                show_title_buttons = true
            };
            switch_toggle = new Gtk.Switch ();
            connection_status_label = new Gtk.Label("");


            // Setup parameters for periodic timer
            update_period = 10000;  // This could be stored in settings

            // extra notifications for debug/development purposes
            debug = false;
            
            // Setup Static UI (where number of widgets doesn't depend on device count)
            create_headerbar();
            
            // Update headerbar widgets according to `is_connected`
            update_headerbar();

            // List of devices in tailnet
            if (is_connected == true) {
                connection_list = cli.get_devices();

                // Show information about first device if it exists
                if (connection_list.length > 0) {
                    selected_device = connection_list[0];

                    // Update based upon tailscale status
                    update_connection_list_box();

                    update_info_box();
                }
            }
            else {
                connection_list = {};
            }
            
            // Assign as ApplicationWindow.titlebar
            titlebar = headerbar; 

            // Setup left pane, depending on connection status
            update_content_grid();

            // Assign as ApplicationWIndow.child
            child = content_grid;

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
    }
}

