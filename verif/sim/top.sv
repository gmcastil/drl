module top;

    import common_pkg::*;
    import tests_pkg::*;

    bit clk;

    initial begin
        base_test test;
        string test_name;
        string log_level;

        if (!$value$plusargs("TESTNAME=%s", test_name)) begin
            $display("Error: TESTNAME not provided. Use +TESTNAME=<test_name>");
            $finish;
        end
        if ($value$plusargs("LOG_LEVEL=%s", log_level)) begin
            case (log_level)
                "DEBUG": begin
                    default_log_level = LOG_DEBUG;
                end
                "INFO": begin
                    default_log_level = LOG_INFO;
                end
                "WARNING": begin
                    default_log_level = LOG_WARNING;
                end
                "ERROR": begin
                    default_log_level = LOG_ERROR;
                end
                "FATAL": begin
                    default_log_level = LOG_FATAL;
                end
                default: begin
                    $fatal(0, "Unknown log level: %s", log_level);
                end
            endcase
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
