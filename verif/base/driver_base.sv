virtual class driver_base extends component_base;

    function new(string name = "driver_base", component_base parent = null);
        super.new(name, parent);
        this.role = "driver";
    endfunction: new

    virtual function void config_phase();
        super.config_phase();
        // Sequencers should register themselves with the configuration database in config_phase
        if (this.parent != null) begin
            if (!config_db::set(this.parent, this.role, this)) begin
                log_fatal("Could not register driver in configuration database");
            end
        end else begin
            log_fatal("Cannot register driver with null parent");
        end

    endfunction: config_phase

    // Derived drivers implement all their own transaction handling, and the base class handles
    // transaction counting, tracking and timestamping
    task process_transaction(ref transaction_base txn);
        if (txn == null) begin
            log_fatal("Cannot process null transaction");
        end
        txn.driver_start = $time;
    endtask: process_transaction

endclass: driver_base

    

