virtual class sequencer_base extends component_base;

    protected int txn_count;
    protected sequence_base seq_queue [$];

    function new(string name = "sequencer_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    task build_phase();
        super.build_phase();
        this.txn_count = 0;
    endtask: build_phase

    task connect_phase();
        super.connect_phase();
    endtask: connect_phase

    // The base sequencer is responsible for adding sequences to the internal sequence queue,
    // popping them out, and calling their start methods.
    task run_phase();
        sequence_base seq;
        forever begin
            // Block until there is a sequence in the queue, then run it
            log_debug("Waiting to receive sequence");
            wait (this.seq_queue.size() != 0);
            log_debug("Sequencer queue is non-zero");
            seq = this.seq_queue.pop_front();
            if (seq == null) begin
                log_fatal("Received null sequence");
            end else begin
                log_debug("Received sequence");
            end
            seq.start();
        end
    endtask: run_phase

    task final_phase();
        super.final_phase();
    endtask: final_phase

    // Adds a sequence to the internal sequence queue for processing into transactions
    task add_sequence(sequence_base seq);
        if (seq == null) begin
            log_fatal("Cannot add null sequence");
        end else begin
            this.seq_queue.push_back(seq);
            log_debug($sformatf("Added sequence to sequencer queue. Queue size is %0d", this.seq_queue.size()));
        end
    endtask: add_sequence

    // Derived sequencers implement their own transaction handling, and the base class handles
    // transaction counting and tracking
    task add_transaction(ref transaction_base txn);
        this.txn_count++;
        log_debug($sformatf("Transaction added. Transaction pending count = %0d", this.txn_count));
    endtask: add_transaction

    // Derived sequencers implement their own response handling (if any)
    task get_response(ref transaction_base txn);
        log_fatal("Derived classes need to extend this themselves");
    endtask: get_response

    // Environments should call this to determine how many pending transactions there are
    function int get_transaction_count();
        return this.txn_count;
    endfunction: get_transaction_count

    // Drivers should call this function when a transaction has been completed
    function bit transaction_completed();
        // If this occurs, it indicates a driver and sequencer that are out of sync
        if (this.txn_count == 0) begin
            log_error("Tried to decrement transaction counter that is zero");
            return 0;
        end else begin
            this.txn_count--;
            log_debug($sformatf("Transaction completed. Transaction pending count = %0d", this.txn_count));
            return 1;
        end
    endfunction: transaction_completed

endclass: sequencer_base

