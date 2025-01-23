virtual class driver_base extends component_base;

    protected sequencer_base sequencer;

    function new(string name = "driver_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_INFO, "Driver biuld phase");
    endtask: build_phase

    // Needs to connect the driver to the sequencer in this phase
    virtual task connect_phase();
        super.connect_phase();
        log(LOG_INFO, "Driver connect phase");
    endtask: connect_phase

    // Pull transactions from the connected sequencer - derived driver objects will have much more
    // sophisticated run phases
    virtual task run_phase();
        super.run_phase();
        log(LOG_INFO, "Driver run phase");
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_INFO, "Driver final phase");
    endtask: final_phase

    virtual task process_transaction(transaction_base txn);
        $fatal("[%s] process_transaction() must be overridden in a derived class.", name);
    endtask: process_transaction

endclass: driver_base

    

