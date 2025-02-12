virtual class test_base extends component_base;

    function new(string name = "test_base", component_base parent = null);
        super.new(name, parent);
    endfunction: new

    task build_phase();
        super.build_phase();
    endtask: build_phase

    task post_build_phase();
        super.post_build_phase();
    endtask: post_build_phase

    task connect_phase();
        super.connect_phase();
    endtask: connect_phase

    task run_phase();
        super.run_phase();
    endtask: run_phase

    task final_phase();
        super.final_phase();
    endtask: final_phase

endclass: test_base

