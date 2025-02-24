class test_root extends object_base;

    static test_root single_instance;
    test_case_base current_test;

    function new(string name = "test_root");
        super.new(name);
    endfunction: new

    static function test_root get_instance();
        if (single_instance == null) begin
            single_instance = new();
        end
        return single_instance;
    endfunction

    task run_test();

        string test_name;

        // Get the provided test name from the test factory
        if (!$value$plusargs("TEST_NAME=%s", test_name)) begin
            $display("No test name provided");
            $fatal(1);
        end
        // TODO This is returning an instantiated test case but it wasn't actually created in the
        // factory. Implement an actual factory in the future that only creates tests on demand
        // instead of requiring someone else (e.g., the tb_top) to create and register all of the
        // test cases up front.
        current_test = test_factory::get_instance().create_test(test_name);
        if (current_test == null) begin
            $display("Test %s not registered in the factory", test_name);
            $fatal(1);
        end
        // Register the test case globally
        config_db#(test_case_base)::set(null, "", "test_case", current_test);

        // Now we're in a position to actually start the lifecycle of the test case
        current_test.run_lifecycle();

    endtask: run_test

endclass

