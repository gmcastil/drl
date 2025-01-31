virtual class sequence_base extends object_base;

    time timestamp;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction;

    pure virtual task run_sequence();

    /* pure virtual function void display(); */

endclass: sequence_base
