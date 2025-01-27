virtual class test_base extends component_base;

    // Signals test case completion
    event test_done;

    function new(string name = "test_base", component_base parent = null);
        super.new(name, parent);
        log(LOG_DEBUG, "", $sformatf("name = %s", name));
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_DEBUG, "BUILD PHASE", "Build phase");
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
        log(LOG_DEBUG, "CONNECT PHASE", "Connect phase");
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        log(LOG_DEBUG, "RUN PHASE", "Run phase");
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_DEBUG, "FINAL PHASE", "Final phase");
    endtask: final_phase

endclass: test_base

