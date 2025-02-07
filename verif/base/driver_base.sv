virtual class driver_base extends component_base;

    function new(string name = "driver_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    task build_phase();
        super.build_phase();
    endtask: build_phase

    task connect_phase();
        super.connect_phase();
    endtask: connect_phase

    task run_phase();
        super.run_phase();
    endtask: run_phase

    task final_phase();
        super.final_phase();
    endtask: final_phase

    task process_transaction(ref transaction_base txn);
        log_fatal("Derived classes need to extend this themselves");
    endtask: process_transaction

endclass: driver_base

    

