class test_base extends component_base;

    function new(string name = "test_base", component_base parent = null);
        super.new(name, parent);
        log(LOG_DEBUG, $sformatf("name = %s", name));
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_DEBUG, "Test base build phase");
    endtask: build_phase

    // Needs to connect the driver to the sequencer in this phase
    virtual task connect_phase();
        super.connect_phase();
        log(LOG_DEBUG, "Test base connect phase");
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        log(LOG_DEBUG, "Test base run phase");
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_DEBUG, "Test final phase");
    endtask: final_phase
endclass: test_base

