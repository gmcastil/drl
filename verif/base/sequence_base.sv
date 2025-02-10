virtual class sequence_base extends object_base;

    time timestamp;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction;

    // This is made virtual because base sequencers need to be able to call this on derived
    // sequences
    pure virtual task start();

    task body();
        log_fatal("Derived classes need to extend body() themselves");
    endtask: body

endclass: sequence_base
