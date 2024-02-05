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
    struct Connection {
        //  public string ipv4_address;
        public string name;
        //  public string username;
        //  public string operating_system;
        public string status;
    
        //  public void print() {
        //      stdout.printf ("%s, %s, %s, %s, %s\n", ipv4_address, name, username, operating_system, status);
        //  }
    }

    class CommandLineInterface : Object {

        //  public bool is_user_an_operator() {
        //      // Checks whether or not `tailscale` command is allowed by this user

        //      // To be implemented
        //      return true;
        //  }

        public bool get_connection_status() {
            Connection[] connection_list = get_devices();

            if (connection_list.length == 0) {
                return false;
            }

            // relies on CLI output sorting, which appears stable
            Connection this_device = connection_list[0];

            if (this_device.status == "online") {
                return true;
            }

            // offline
            return false;
        }

        public void wait_for_connection_status_to_stabalize() {
            // sleep for a bit to allow `tailscale up` to propagate to `tailscale status`
            double wait = 0.75 * 1000000.0;
            int wait_in_seconds = (int)wait; // cast double to int
            Thread.usleep (wait_in_seconds); 
        }

        public int attempt_connection() {
            string command_stdout;
            string command_stderr;
            int command_status;

            try {
                Process.spawn_command_line_sync ("tailscale up",
                                            out command_stdout,
                                            out command_stderr,
                                            out command_status);
            } catch (SpawnError e) {
                print ("Error: %s\n", e.message);
                return 1;
            }
            return 0;
        }

        public int attempt_disconnection() {
            string command_stdout;
            string command_stderr;
            int command_status;

            try {
                Process.spawn_command_line_sync ("tailscale down",
                                            out command_stdout,
                                            out command_stderr,
                                            out command_status);
            } catch (SpawnError e) {
                print ("Error: %s\n", e.message);
                return 1;
            }
            return 0;
        }


        public Connection[] get_devices() {
            string command_stdout;
            string command_stderr;
            int command_status;

            try {
                Process.spawn_command_line_sync ("tailscale status",
                                            out command_stdout,
                                            out command_stderr,
                                            out command_status);
            } catch (SpawnError e) {
                print ("Error: %s\n", e.message);
            }

            Connection[] connection_list = {};

            bool end_of_connections = false;
            
            //  print("\n----------\n");
            foreach (string line in command_stdout.split("\n")) {
        
                // placeholders
                string result = "";
                string[] line_parts = {};
                int number_of_parts = 0;

                // if there are still connections to parse
                if (end_of_connections == false) {
                    // Replace 1 or more spaces with single space
                    try {
                        Regex regex = / +/;
                        result = regex.replace (line, line.length, 0, " ");
                    }
                    catch (RegexError r) {
                        print("RegexError: %s\n", r.message);
                    }
                    
                    line_parts = result.split(" ");        
                    number_of_parts = line_parts.length;
                }
        
                // There is a blank line between device list and comments
                if (number_of_parts == 0) {
                    end_of_connections = true;
                }
        
                if (end_of_connections == false) {
                    // parse lines
                    //  print("parse lines\n");
                    //  print("L: %s\n", line);
                    //  print("R: %s\n", result);
        
                    if (number_of_parts == 5) {
        
                        string status = ""; 
                        if (line_parts[4] == "-") {
                            status = "online";
                        }
                        else {
                            status = line_parts[4];
                        }
        
                        var connection = Connection() {
                            //  ipv4_address = line_parts[0],
                            name = line_parts[1],
                            //  username = line_parts[2].replace("@",""),
                            //  operating_system = line_parts[3],
                            status = status,
                        };
                        connection_list += connection;
                        //  connection.print();
                    }
        
                    //  print("----------\n");
                }
            }
            return connection_list;
        }
    }
}

