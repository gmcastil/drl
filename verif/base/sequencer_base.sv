virtual class sequencer_base extends component_base;

    // The base sequencer handles all objection management
    protected objection_mgr p_obj_mgr;

    // Internal transaction counter needs a lock to prevent race conditions otherwise
    protected int txn_count;
    protected semaphore txn_count_sem;

    // The sequence queue does not need to be locked because it is assumed that all sequences are
    // queued up before the sequencer processes them
    protected sequence_base seq_queue [$];

    // Indicates that the seqeuncer is busy processing a sequence into transactions
    protected bit active;

    function new(string name, component_base parent);
        super.new(name, parent);
        this.p_obj_mgr = null;
        this.role = "sequencer";
    endfunction: new

    virtual function void build_phase();
        // Build any children first
        super.build_phase();

        // Initialize locks, status, and counters
        this.active = 0;
        this.txn_count = 0;
        this.txn_count_sem = new(1);

    endfunction: build_phase

    virtual function void pre_run_phase();
        object_base from_db;

        super.pre_run_phase();

        if (!config_db::get(null, "obj_mgr", from_db)) begin
            log_fatal("Could not retrieve object manager from configuration database");
        end
        if (from_db == null) begin
            log_fatal("Objection manager reference from configuration database was null");
        end

        if (!$cast(p_obj_mgr, from_db)) begin
            log_fatal("Object manager from configuration database not of expected type");
        end else begin
            log_debug("Obtained objection manager from configuration database");
        end

    endfunction: pre_run_phase

    // The base sequencer is responsible for adding sequences to the internal sequence queue,
    // popping them out, and calling their start methods.
    virtual task run_phase();
        sequence_base seq;
        // This objection gets dropped later at the end of the last transaction in the last sequence,
        // when the seqeunce counter and transaction counters are both zero.
        //
        // Warning for developers: Test sequences must not rely on fixed time delays in test
        // cases (i.e., outside of sequences). Doing so will almost certainly lead to the following
        // - Timing violations affecting objects being raised or dropped
        // - Simulations terminating early or hanging
        // - Hard to find race conditions
        //
        // Instead, test cases should rely on 
        // - Using sequences to generate all delays or transactions
        // - Synchronization based on DUT events
        // - Handshakes
        //
        // TL;DR Don't do things like `#100ns` in your test cases. It would be bad.
        //
        p_obj_mgr.raise(this);
        forever begin
            // Block until there is a sequence in the queue, then run it
            log_debug("Waiting to receive sequence");
            wait (this.seq_queue.size() != 0);

            log_debug("Sequencer queue is non-zero");
            seq = this.seq_queue.pop_front();
            if (seq == null) begin
                log_fatal("Received null sequence");
            end

            this.active = 1;
            log_debug("Starting sequence");
            seq.start();
            log_debug("Sequence complete");
            this.active = 0;
        end
    endtask: run_phase

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
    // transaction counting, tracking and timestamping.
    task add_transaction(ref transaction_base txn);
        this.txn_count_sem.get();
        // It is assumed here that transactions were created by the child class before adding
        txn.created = $time;
        this.txn_count++;
        this.txn_count_sem.put();
        log_debug($sformatf("Transaction added at %0t. Transaction pending count = %0d", txn.created, this.txn_count));
    endtask: add_transaction

    // Derived sequencers implement their own response handling (if any)
    task get_response(ref transaction_base txn);
        log_fatal("Derived classes need to extend this themselves");
    endtask: get_response

    // Environments should call this to determine how many pending transactions there are
    function int get_transaction_count();
        return this.txn_count;
    endfunction: get_transaction_count

    // Drivers must call this function when a transaction has been completed
    task transaction_completed();
        this.txn_count_sem.get();

        // This would indicate a driver and sequencer that were out of sync or some other logic error
        // that should never occur
        if (this.txn_count == 0) begin
            this.txn_count_sem.put();
            log_fatal("Driver attempted to complete a transaction when no transactions were pending.");
        end

        // Safe to decrement this now
        this.txn_count--;
        log_debug($sformatf("Transaction completed. Transaction pending count = %0d", this.txn_count));

        // While we're still locked, check the number of pending transactions and seqeunces as well
        // as whether we're actively processing a sequence to see if we can drop our objection.
        // Woe to thee that adds sequences after time has started.
        if (this.txn_count == 0 && this.seq_queue.size() == 0 && this.active == 0) begin
            log_debug("All sequences and transactions are completed");
            this.p_obj_mgr.drop(this);
        end
        this.txn_count_sem.put();

    endtask: transaction_completed

endclass: sequencer_base

