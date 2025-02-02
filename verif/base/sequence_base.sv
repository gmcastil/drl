virtual class sequence_base extends object_base;

    time timestamp;
    sequencer_base seqr;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction;

    pure virtual function void start(sequencer_base seqr);

    pure virtual task body();

    /* pure virtual function void display(); */

endclass: sequence_base
