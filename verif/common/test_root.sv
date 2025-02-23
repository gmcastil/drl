// The logger singleton class requires callers of this type, so we need a proxy object to enable
// logging for components outside the test hierarchy.
class logger_proxy extends object_base;

    function new(string name);
        super.new(name);
    endfunction: new

endclass: logger_proxy

class test_root;

    static test_root single_instance;
    test_case_base test_case;
    logger_proxy log_proxy;

    function static test_root get_instance();
        if (single_instance == null) begin
            single_instance = new();
            initialize();
        end
        return single_instance;
    endfunction

    static function void initialize();
        log_proxy = new("log_proxy");
    end

    function void log(string msg);
        logger::get_instance().log(

    endfunction

    function void run_test(string test_name);
        log.print($sformatf("Instantiating test: %s", test_name));
        current_test = 
            if (current_test == null) begin
                log.print($sformatf("ERROR: Test %s not found!", test_name));
                return;
        end

        // FIXME: Hacks since we dont have a test factory in the framework yet!
        encoder_test_factory::init("test_factory");
        test_case = encoder_test_factory::create_test(test_name);

        // Register the test case 
        config_db::set(this, "", "test_case", test_case);

        // Run the test
        test_case.run_lifecycle();

    endfunction

endclass

