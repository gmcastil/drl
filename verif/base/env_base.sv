virtual class env_base extends component_base;

    function new(string name = "env_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_DEBUG, "BUILD PHASE", "Environment base build phase");
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
        log(LOG_DEBUG, "CONNECT PHASE", "Environment base connect phase");
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        log(LOG_DEBUG, "RUN PHASE", "Environment base run phase");
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_DEBUG, "FINAL PHASE", "Environment final phase");
    endtask: final_phase

endclass: env_base

