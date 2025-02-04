virtual class driver_base extends component_base;

    function new(string name = "driver_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
    endtask: final_phase

    pure virtual task process_transaction(ref transaction_base txn);

endclass: driver_base

    

