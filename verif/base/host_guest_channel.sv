class host_guest_channel #(type T) extends component_base;

    mailbox #(T) host_to_guest;
    mailbox #(T) guest_to_host;

    string host_name;
    string guest_name;

    function new(string name, component_base parent = null,
                    string host_name = "", string guest_name = "");

        super.new(name, parent);
        this.host_to_guest = new();
        this.guest_to_host = new();

        this.host_name = host_name;
        this.guest_name = guest_name;

        if (this.host_to_guest == null) begin
            log(LOG_FATAL, $sformatf("Could not initialize %s -> %s channel", host_name, guest_name));
            $fatal(1);
        end
        if (this.guest_to_host == null) begin
            log(LOG_ERROR, $sformatf("Could not initialize %s <- %s channel", host_name, guest_name));
            $fatal(1);
        end

        else begin
            log(LOG_INFO, $sformatf("Created %s -> %s channel", this.host_name, this.guest_name));
        end

    endfunction: new

    task send_to_guest(T txn);
        if (txn == null) begin
            log(LOG_FATAL, "Attempted to send or receive a null transaction");
            $fatal(1);
        end
        this.host_to_guest.put(txn);
        log(LOG_DEBUG, $sformatf("Type: %s Host: %s -> Guest: %s Txn Type: %s",
                "SEND", this.host_name, this.guest_name, $typename(T)));
    endtask: send_to_guest

    task send_to_host(T txn);
        if (txn == null) begin
            log(LOG_FATAL, "Attempted to send or receive a null transaction");
            $fatal(1);
        end
        this.guest_to_host.put(txn);
        log(LOG_DEBUG, $sformatf("Type: %s Host: %s <- Guest: %s Txn Type: %s",
                "SEND", this.host_name, this.guest_name, $typename(T)));
    endtask: send_to_host

    task recv_from_host(ref T txn);
        this.host_to_guest.get(txn);
        log(LOG_DEBUG, $sformatf("Type: %s Host: %s -> Guest: %s Txn Type: %s",
                "RECV", this.host_name, this.guest_name, $typename(T)));
    endtask: recv_from_host

    task recv_from_guest(ref T txn);
        this.guest_to_host.get(txn);
        log(LOG_DEBUG, $sformatf("Type: %s Host: %s <- Guest: %s Txn Type: %s",
                "RECV", this.host_name, this.guest_name, $typename(T)));
    endtask: recv_from_guest

endclass: host_guest_channel

