class env_test extends base_test;

    // Properties
    env_base env;

    // Constructor
    function new();
        super.new();  // Call parent constructor
        $display("Initializing environment test...");
    endfunction

    // Run the test
    virtual task run_test();
        $display("Running environment test...");

        // Instantiate the environment
        env = new("test_env", null);

        // Execute lifecycle phases
        env.build_phase();
        $display("Environment build phase completed.");

        env.connect_phase();
        $display("Environment connect phase completed.");

        env.run_phase();
        $display("Environment run phase completed.");

        env.final_phase();
        $display("Environment final phase completed.");

        $finish;
    endtask

endclass: test_env

