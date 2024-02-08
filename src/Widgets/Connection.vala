
class Tailnet.ConnectionListItem : Gtk.Box {

    public Tailnet.Connection device {get; construct;}
    public bool detailed_view {get; construct; default = false;}

    public ConnectionListItem(Tailnet.Connection device) {
        Object(device: device);
    }

    public ConnectionListItem.with_details(Tailnet.Connection device) {
        Object(device: device, detailed_view: true);
    }

    construct {
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

        append(connection_label_top_row);
            
        
        if (detailed_view == true) {
            Gtk.Button copy_name_button= new Gtk.Button.from_icon_name ("edit-copy");
            copy_name_button.focusable = false;
            //  copy_os_button.label = device.operating_system;
            copy_name_button.clicked.connect(() => {
                set_clipboard(device.name);
            });
            connection_label_top_row.append(copy_name_button);

            if (device.ipv4_address != null) {
                append(get_detailed_row(device.ipv4_address));
            }

            if (device.ipv6_address != null) {
                append(get_detailed_row(device.ipv6_address));
            }
    
            if (device.operating_system != null) {
                append(get_detailed_row(device.operating_system));
            }

            if (device.username != null) {
                append(get_detailed_row(device.username));
            }

            spacing = 10;
        }
        else {
            append(get_simple_row(device.ipv4_address));
            spacing = 2;
        }

        orientation = Gtk.Orientation.VERTICAL;

        set_margin_top(0);
        set_margin_bottom(0);

        
    }

    public Gtk.Label get_simple_row(string text) {
        Gtk.Label row = new Gtk.Label(device.ipv4_address);
        row.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);
        row.halign = Gtk.Align.START;
        row.set_margin_start (35);
        row.set_margin_end(25);
        return row;
    }

    public Gtk.Box get_detailed_row(string text) {
        Gtk.Box row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        Gtk.Label label = new Gtk.Label(text);

        Gtk.Button copy_button= new Gtk.Button.from_icon_name ("edit-copy");
        copy_button.focusable = false;
        //  copy_os_button.label = device.operating_system;
        copy_button.clicked.connect(() => {
            set_clipboard(text);
        });
        label.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);
        row.halign = Gtk.Align.START;
        row.set_margin_start (35);
        row.set_margin_end(25);

        row.append(label);
        row.append(copy_button);
        return row;
    }

    public void set_clipboard(string text) {
        var window = new Gtk.Window ();
                    //  var display = window.get_display ();
        var clipboard = window.get_clipboard();

        clipboard.set_text (text);
    }
}
