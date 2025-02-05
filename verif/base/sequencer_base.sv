virtual class sequencer_base extends component_base;

    protected sequence_base seq_queue [$];

    function new(string name = "sequencer_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
    endtask: connect_phase

    virtual task run_phase();
        sequence_base seq;
        forever begin
            // Block until there is a sequence in the queue, then run it
            wait (this.seq_queue.size() != 0);
            seq = this.seq_queue.pop_front();
            if (seq == null) begin
                log_fatal("Received null sequence");
            end
            seq.start(this);
            seq.body();
        end
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
    endtask: final_phase

    virtual function void add_sequence(sequence_base seq);
        if (seq != null) begin
            this.seq_queue.push_back(seq);
        end
    endfunction: add_sequence

    pure virtual task add_transaction(transaction_base txn);

    pure virtual task get_response(ref transaction_base txn);

endclass: sequencer_base

