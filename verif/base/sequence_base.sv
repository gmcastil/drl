virtual class sequence_base extends object_base;

    time timestamp;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction;

    // This is made virtual because base sequencers need to be able to call this on derived
    // sequences
    virtual task start();
        log_fatal("Derived classes need to extend start() themselves");
    endtask: start

    task body();
        log_fatal("Derived classes need to extend body() themselves");
    endtask: body

    function void log(log_level_t level, string msg, string id = "");
        super.log(level, this.get_name(), msg, id);
    endfunction: log

	function void log_fatal(string msg, string id = "");
        super.log_fatal(this.get_name(), msg, id);
    endfunction: log_fatal

endclass: sequence_base
