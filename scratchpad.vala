
struct Connection {
    string ipv4_address;
    string node_name;
    string username;
    string operating_system;
    string status;

    public void print() {
        stdout.printf ("%s, %s, %s, %s, %s\n", ipv4_address, node_name, username, operating_system, status);
    }
}

void main () {
    
    string command_stdout;
    string command_stderr;
    int command_status;

    try {
        Process.spawn_command_line_sync ("tailscale status",
                                    out command_stdout,
                                    out command_stderr,
                                    out command_status);

        // Output: <File list>
        print ("stdout:\n");
        // Output: ````
        print (command_stdout);
        //  print ("stderr:\n");
        //  print (command_stderr);
        //  // Output: ``0``
        //  print ("Status: %d\n", command_status);
    } catch (SpawnError e) {
        print ("Error: %s\n", e.message);
    }

    

    Connection[] connection_list = {};

    bool end_of_connections = false;
    int number_of_parts = 0;
    print("\n----------\n");
    foreach (string line in command_stdout.split("\n")) {

        // placeholders
        string result = "";
        string[] line_parts = {};
        if (end_of_connections == false) {

            // Replace 1 or more spaces with single space
            Regex regex = / +/;
		    result = regex.replace (line, line.length, 0, " ");
            line_parts = result.split(" ");        
            number_of_parts = line_parts.length;
            //  print("x");
            //  print(number_of_parts.to_string());
            //  print("\n");
        }

        if (number_of_parts == 0) {
            end_of_connections = true;
        }

        if (end_of_connections == false) {
            // parse lines
            print("parse lines\n");
            print("L: %s\n", line);
            print("R: %s\n", result);

            if (number_of_parts == 5) {

                string status = ""; 
                if (line_parts[4] == "-") {
                    status = "online";
                }
                else {
                    status = line_parts[4];
                }

                var connection = Connection() {
                    ipv4_address = line_parts[0],
                    node_name = line_parts[1],
                    username = line_parts[2].replace("@",""),
                    operating_system = line_parts[3],
                    status = status,
                };
                connection_list += connection;
                connection.print();
            }

            print("----------\n");
        }
    }

    print("Tailnet:\n");
    foreach (Connection tailnet in connection_list) {
        tailnet.print();
    }
}
