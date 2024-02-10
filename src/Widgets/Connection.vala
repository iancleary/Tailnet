class Tailnet.ConnectionInfoItem : Gtk.Button {
    // Setup parameters for periodic timer
    private int update_period;
    private uint delayed_changed_id;
    private bool in_callback;
    private int wait_in_seconds;

    private Gtk.Box content_box;
    private Gtk.Button copy_button;
    private Gtk.Button copy_complete_button;

    

    public string information_to_display {get; construct;}

    

    public ConnectionInfoItem(string information_to_display) {
        Object(information_to_display: information_to_display);
    }


    private void reset_timeout(){
        if(delayed_changed_id > 0)
            Source.remove(delayed_changed_id);
        delayed_changed_id = Timeout.add(update_period, timeout);
    }
    
    private bool timeout(){
        // do actual search here!

        update_button_back();

        delayed_changed_id = 0;

        return false;
    }

    public void wait_to_ease_transition() {
        Thread.usleep (wait_in_seconds); 
    }

    public void update_button_back() {


        if (in_callback == true) {
            // Ease transition time
            wait_to_ease_transition();
            in_callback = false;
        }
        
        copy_complete_button.set_visible(false);
        copy_button.set_visible(true);
        
        // Reset
        reset_timeout();
    }


    construct {

        focusable = false;
        add_css_class(Granite.STYLE_CLASS_FLAT);

        content_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        halign = Gtk.Align.START;
        content_box.set_margin_start (35);
        content_box.set_margin_end(25);

        set_child(content_box);

        Gtk.Label label = new Gtk.Label(information_to_display);
        label.add_css_class(Granite.STYLE_CLASS_DIM_LABEL);

        content_box.append(label);
        copy_button = new Gtk.Button.from_icon_name("edit-copy") {focusable = false};
        copy_complete_button = new Gtk.Button.from_icon_name("emblem-default") {focusable = false};

        copy_complete_button.set_visible(false);
        content_box.append(copy_button);
        content_box.append(copy_complete_button);


        clicked.connect(() => {
            in_callback = true;
            set_clipboard(information_to_display);
            copy_button.set_visible(false);
            copy_complete_button.set_visible(true);
           
        });

        // wait in seconds should be half of update_period
        update_period = 500; // milliseconds -> 0.5 seconds
        double wait = 0.25 * 1000000.0; // microseconds -> 0.25 seconds
        wait_in_seconds = (int)wait; // cast double to int
        

        set_margin_top(0);
        set_margin_bottom(0);

         // setup periodic reset of button
         in_callback = false;
         timeout();

         
    }

    public void set_clipboard(string text) {
        var window = new Gtk.Window ();
                    //  var display = window.get_display ();
        var clipboard = window.get_clipboard();

        clipboard.set_text (text);
    }

}


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
            //  Gtk.Button copy_name_button= new Gtk.Button.from_icon_name ("edit-copy");
            //  copy_name_button.focusable = false;
            //  //  copy_os_button.label = device.operating_system;
            //  copy_name_button.clicked.connect(() => {
            //      set_clipboard(device.name);
            //  });
            //  connection_label_top_row.append(copy_name_button);

            // magic dns: https://tailscale.com/kb/1081/magicdns
            if (device.ipv4_address != null) {
                append(get_detailed_row("http://"+device.name));
            }
            
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

    public ConnectionInfoItem get_detailed_row(string text) {
        ConnectionInfoItem button_row = new ConnectionInfoItem(text); 
        return button_row;
    }
}
