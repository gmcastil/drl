class host_guest_channel #(type T) extends object_base;

    mailbox #(T) host_to_guest;
    mailbox #(T) guest_to_host;

    string host_name;
    string guest_name;

    function new(string name, string host_name = "", string guest_name = "");

        super.new(name);
        this.host_to_guest = new();
        this.guest_to_host = new();

        this.host_name = host_name;
        this.guest_name = guest_name;

        if (this.host_to_guest == null) begin
            `log_fatal($sformatf("Could not initialize %s -> %s channel", host_name, guest_name));
        end
        if (this.guest_to_host == null) begin
            `log_fatal($sformatf("Could not initialize %s <- %s channel", host_name, guest_name));
        end

        `log_debug($sformatf("Created %s -> %s channel", this.host_name, this.guest_name));

    endfunction: new

    task send_to_guest(T txn);
        if (txn == null) begin
            `log_fatal("Attempted to send or receive a null transaction");
        end
        this.host_to_guest.put(txn);
        `log_debug($sformatf("%s: %s -> %s Txn Type: %s",
                "HOST -> GUEST (put)", this.host_name, this.guest_name, $typename(T)));
    endtask: send_to_guest

    task send_to_host(T txn);
        if (txn == null) begin
            `log_fatal("Attempted to send or receive a null transaction");
        end
        this.guest_to_host.put(txn);
        `log_debug($sformatf("%s: %s <- %s Txn Type: %s",
                "GUEST -> HOST (put)", this.host_name, this.guest_name, $typename(T)));
    endtask: send_to_host

    task recv_from_host(ref T txn);
        this.host_to_guest.get(txn);
        `log_debug($sformatf("%s: %s -> %s Txn Type: %s",
                "HOST -> GUEST (get)", this.host_name, this.guest_name, $typename(T)));
    endtask: recv_from_host

    task recv_from_guest(ref T txn);
        this.guest_to_host.get(txn);
        `log_debug($sformatf("%s: %s -> %s Txn Type: %s",
                "GUEST -> HOST (get)", this.host_name, this.guest_name, $typename(T)));
    endtask: recv_from_guest

endclass: host_guest_channel

