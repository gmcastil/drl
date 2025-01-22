class driver_base extends component_base;

    protected mailbox txn_queue;

    function new(string name, component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_INFO, "Driver biuld phase");
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
        log(LOG_INFO, "Driver connect phase");
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        log(LOG_INFO, "Driver run phase");
        forever begin
            transaction_base txn;
            txn_queue.get(txn);
            if (!txn) begin
                log(LOG_WARNING, "Null transaction received, skipping");
                continue;
            end
            execute_transaction(txn);
        end
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_INFO, "Driver final phase");
    endtask: final_phase


    

