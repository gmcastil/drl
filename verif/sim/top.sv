module top;

    import tests_pkg::*;

    bit clk;

    initial begin
        base_test test;
        string test_name;

        if (!$value$plusargs("TESTNAME=%s", test_name)) begin
            $display("Error: TESTNAME not provided. Use +TESTNAME=<test_name>");
            $finish;
        end

        if (test_name == "env_test") begin
            test = env_test::new();
        end else begin
            $display("Error: Unknown test '%s'", test_name);
            $finish;
        end

        test.run_test();

        $finish;
    end

endmodule: top
