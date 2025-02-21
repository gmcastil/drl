virtual class driver_base extends component_base;

    function new(string name, component_base parent);
        super.new(name, parent);
    endfunction: new

    // Derived drivers implement all their own transaction handling, and the base class handles
    // transaction counting, tracking and timestamping
    task process_transaction(transaction_base txn);
        if (txn == null) begin
            log_fatal("Cannot process null transaction");
        end
    endtask: process_transaction

endclass: driver_base

    

