class base_test;

    function new();
        $display("Initializing base test...");
    endfunction: new

    virtual task run_test();
        $fatal(1, "Error: Base test case must be extended");
    endtask: run_test

endclass: base_test
