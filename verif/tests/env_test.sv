class env_test extends base_test;

    /* env_base env; */

    function new();
        super.new();
        $display("Initializing environment test...");
    endfunction: new

    virtual task run_test();
        $display("Running environment test...");

        /* // Instantiate the environment */
        /* env = new("test_env", null); */

        /* // Execute lifecycle phases */
        /* env.build_phase(); */
        /* $display("Environment build phase completed."); */

        /* env.connect_phase(); */
        /* $display("Environment connect phase completed."); */

        /* env.run_phase(); */
        /* $display("Environment run phase completed."); */

        /* env.final_phase(); */
        /* $display("Environment final phase completed."); */

        $finish;
    endtask

endclass: env_test

