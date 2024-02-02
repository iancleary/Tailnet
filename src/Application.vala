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

    protected override void activate () {
        string label_str = _("Hello Again World!");
        string title = _("Hello World");
        var label = new Gtk.Label (label_str);
   
        var main_window = new Gtk.ApplicationWindow (this) {
            child = label,
            default_height = 300,
            default_width = 300,
            title = title
        };
        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}