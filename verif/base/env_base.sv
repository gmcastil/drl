virtual class env_base extends component_base;

    function new(string name = "env_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        $display("[%s] build_phase: Setting up environment", this.name);
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
        $display("[%s] connect_phase: Connecting environment components", this.name);
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        $display("[%s] run_phase: Running environment level operations", this.name);
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        $display("[%s] final_phase: Cleaning up environemtn", this.name);
    endtask: final_phase

endclass: env_base

