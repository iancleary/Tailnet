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
    public class ReconnectPromptBox : Gtk.Box {

        // don't understand how to 'delegate' and which direction between classes to do that
        //  Problem statement: connect 'connect_button.clicked.connect' to reconnect function of MainWindow

        public MainWindow main_window {get; construct; }

        public ReconnectPromptBox( MainWindow main_window) {
            Object (main_window: main_window);
        }
    
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 5;
    
            // Bottom margin makes it "feel" more centered,
            // since the button is at the bottom of the box
            set_margin_bottom(100);
            
            Gtk.MenuButton power_icon = new Gtk.MenuButton () {
                can_focus = false,
                icon_name = "system-shutdown-symbolic",
                primary = true
            };
    
            append(power_icon);
    
            Gtk.Label disconnected_label = new Gtk.Label(null);
            disconnected_label.set_markup ("<b>Not Connected</b>");
            disconnected_label.set_margin_start (25);
            disconnected_label.set_margin_end (25);
            disconnected_label.set_margin_top(0);
            disconnected_label.set_margin_bottom(0);
    
            append(disconnected_label);
    
            Gtk.Label disconnected_detailed_label_top = new Gtk.Label("Connect again to talk to");
            disconnected_detailed_label_top.set_margin_start (25);
            disconnected_detailed_label_top.set_margin_end (25);
            disconnected_detailed_label_top.set_margin_top(5);
            disconnected_detailed_label_top.set_margin_bottom(0);
    
            append(disconnected_detailed_label_top);
    
            Gtk.Label disconnected_detailed_label_bottom = new Gtk.Label("the other devices in the tailnet.");
            disconnected_detailed_label_bottom.set_margin_start (25);
            disconnected_detailed_label_bottom.set_margin_end (25);
            disconnected_detailed_label_bottom.set_margin_top(0);
            disconnected_detailed_label_bottom.set_margin_bottom(5);
            append(disconnected_detailed_label_bottom);
    
    
            //  var connect_button = new Gtk.Button();
            Gtk.Button connect_button = new Gtk.Button();
            Gtk.Label connect_button_label = new Gtk.Label(null);
            connect_button_label.set_markup("<b>Connect</b>");
            connect_button_label.set_margin_start (25);
            connect_button_label.set_margin_end (25);
            connect_button_label.set_margin_top(5);
            connect_button_label.set_margin_bottom(5);
    
            connect_button.set_margin_start(5);
            connect_button.set_margin_end(5);
            
            connect_button.child = connect_button_label;
            connect_button.add_css_class (Granite.STYLE_CLASS_FLAT);
            append(connect_button);
    
            // Button pressed transitions from OFF to ON 
            connect_button.clicked.connect (main_window.reconnect );
        }
    
    }
}


