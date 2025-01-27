/*
 * The `uart_test_base` provides all common setup logic in the `build_phase` and
 * `connect_phase`. These are written with the assumption that all derived test cases
 * will need and rely on this functionality.
 */

class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends test_base;

    uart_config_t dut_cfg;
    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;
    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;

    function new(string name,
        axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
        uart_config_t dut_cfg,
        component_base parent = null);

        super.new(name, parent);

        this.axi4l_bfm = axi4l_bfm;
        this.dut_cfg = dut_cfg;
        log(LOG_DEBUG, "UART base test constructor");
    endfunction: new

    virtual task build_phase();
        super.build_phase();
        log(LOG_INFO, "Build phase started");
        this.env = new("uart_env", this.axi4l_bfm, this);
        this.env.build_phase();
        log(LOG_INFO, "Build phase finished");
    endtask: build_phase

    virtual task connect_phase();
        super.connect_phase();
        log(LOG_DEBUG, "UART test base connect phase");
    endtask: connect_phase

    virtual task run_phase();
        super.run_phase();
        log(LOG_DEBUG, "UART test base run phase");
        ->test_done;
    endtask: run_phase

    virtual task final_phase();
        super.final_phase();
        log(LOG_DEBUG, "UART test base final phase");
    endtask: final_phase

endclass: uart_test_base

