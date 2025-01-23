class env_test extends base_test;

    env_base env;

    function new();
        super.new();
        $display("Initializing environment test...");
    endfunction: new

    virtual task run_test();
        $display("Running environment test...");

        // Instantiate the environment
        env = new("ENV", null);

        // Execute lifecycle phases
        env.build_phase();
        $display("Environment build phase completed.");

        env.connect_phase();
        $display("Environment connect phase completed.");

        env.run_phase();
        $display("Environment run phase completed.");

        env.final_phase();
        $display("Environment final phase completed.");

        $display("current log level = %s", env.get_log_level());
        env.log(LOG_DEBUG, "debug");
        env.log(LOG_INFO, "info");
        env.log(LOG_WARN, "warning");
        env.log(LOG_ERROR, "error");
        env.log(LOG_FATAL, "fatal");
        $finish;
    endtask

endclass: env_test

