// Globally accessible test container - obtains the test case from the test factory,
// sets it to be the current teest, and then runs its lifecycle.
class test_root;

    static test_root single_instance;
    string name;

    test_case_base current_test;

    function new(string name);
        this.name = name; 
    endfunction: new

    static function test_root get_instance();
        if (single_instance == null) begin
            single_instance = new("test_root");
        end
        return single_instance;
    endfunction

    task run_test();

        string test_name;

        // Get the provided test name from the test factory
        if (!$value$plusargs("TEST_NAME=%s", test_name)) begin
            `report_fatal(this.get_name(), "No test name was provided");
        end
        // TODO This is returning an instantiated test case but it wasn't actually created in the
        // factory. Implement an actual factory in the future that only creates tests on demand
        // instead of requiring someone else (e.g., the tb_top) to create and register all of the
        // test cases up front.
        current_test = test_factory::get_instance().create_test(test_name);
        if (current_test == null) begin
            `report_fatal(this.get_name(), $sformatf("Test %s not registered in the factory", test_name));
        end

        // Register the test case globally
        config_db#(test_case_base)::set(null, "", "test_case", current_test);

        // Now we're in a position to actually start the lifecycle of the test case
        `report_info(this.get_name(), $sformatf("Started test case %s", current_test.get_name()), LOG_LOW);
        current_test.run_lifecycle();

    endtask: run_test

    function string get_name();
        return this.name;
    endfunction: get_name

endclass

