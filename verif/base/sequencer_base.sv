virtual class sequencer_base extends component_base;

    semaphore txn_queue_sem;
    protected mailbox txn_queue;

    function new(string name = "sequencer_base", component_base parent = null);
        super.new(name, parent);
        this.txn_queue_sem = new(1);
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

    virtual task add_transaction(transaction_base txn);
        this.txn_queue_sem.get();
        if (this.txn_queue == null) begin
            log(LOG_WARN, "Sequencer queue is uninitialized");
        end else begin
            this.txn_queue.put(txn);
        end
        this.txn_queue_sem.put();
    endtask: add_transaction

    virtual task get_next_transaction(ref transaction_base txn);
        this.txn_queue_sem.get();
        if (this.txn_queue == null) begin
            log(LOG_WARN, "Sequencer queue is uninitialized");
        end else begin
            this.txn_queue.get(txn);
        end
        this.txn_queue_sem.put();
    endtask: get_next_transaction

    // Potential for race condition here, so be mindful and make a task
    // in the future if access needs to be atomic
    function automatic bit is_empty();
        bit retval;

        if (this.txn_queue == null) begin
            log(LOG_WARN, "Sequencer queue is uninitialized");
        end 

        if (this.txn_queue.num() == 0) begin
            retval = 0;
        end else begin
            retval = 1;
        end
        return retval;

    endfunction: is_empty

endclass: sequencer_base

