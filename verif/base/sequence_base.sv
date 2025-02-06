virtual class sequence_base extends object_base;

    time timestamp;
    sequencer_base seqr;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction;

    pure virtual task start(sequencer_base seqr);

    pure virtual task body();

    /* pure virtual function void display(); */

    function void log(log_level_t level, string msg, string id = "");
        super.log(level, this.get_name(), msg, id);
    endfunction: log

	function void log_fatal(string msg, string id = "");
        super.log_fatal(this.get_name(), msg, id);
    endfunction: log_fatal

endclass: sequence_base
