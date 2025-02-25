class test_factory;

    static test_factory singleton_instance;
    string name;

    // In the UVM world, they have an entire complicated machine involving copying, and cloning, and
    // dynamically creating tests at runtime rather than all up front at once.  Since we don't need
    // or want zillions of test cases, a simple storage mechanism is sufficient.  In UVM, this would
    // be referred to as `creators` or something of that nature.  Since we are absolutely NOT doing
    // that here, a more approprpiate name for the container is used.
    static test_case_base test_case_handles [string];

    function new(string name);
        this.name = name; 
    endfunction: new

    static function test_factory get_instance();
        if (singleton_instance == null) begin
            singleton_instance = new("test_factory");
        end
        return singleton_instance;
    endfunction: get_instance

    function test_case_base create_test(string test_name);
        return test_case_handles[test_name];
    endfunction: create_test

    function void register(string test_name, test_case_base test_case);
        singleton_instance.test_case_handles[test_name] = test_case;
        `report_info(this.get_name(), $sformatf("Registered test name '%s' with the test factory", test_case.get_name()), LOG_LOW);
    endfunction: register

    function string get_name();
        return this.name;
    endfunction: get_name

endclass: test_factory
