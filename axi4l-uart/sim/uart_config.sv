class uart_config #();

    string device;
    int unsigned axi_base_addr;
    int unsigned axi_base_mask;
    int unsigned axi_addr_width;
    int unsigned axi_data_width;
    bit rx_enable;
    bit tx_enable;

    function new(uart_config_t dut_config);
        this.device = dut_config.device;
        this.rx_enable = dut_config.rx_enable;
        this.tx_enable = dut_config.tx_enable;
        this.axi_base_addr = dut_config.axi_base_addr;
        this.axi_base_mask = dut_config.axi_base_mask;
        this.axi_addr_width = dut_config.axi_addr_width;
        this.axi_data_width = dut_config.axi_data_width;
    endfunction: new

    // Returns the 32-bit aligned register address
    function int unsigned get_register_addr(string reg_name);
        int unsigned reg_addr;
        if (reg_name == "SCRATCH_REG") begin
            reg_addr = 15 << 2;
        end else begin
            $display("Undefined register");
        end
        return reg_addr;
    endfunction: get_register_addr

    function void display();
        $display("UART Configuration:");
        $display("  Device:          %s", device);
        $display("  RX Enable:       %b", rx_enable);
        $display("  TX Enable:       %b", tx_enable);
        $display("  AXI Base Addr:   0x%08h", axi_base_addr);
        $display("  AXI Base Mask:   0x%08h", axi_base_mask);
        $display("  AXI addr         %d", axi_addr_width);
        $display("  AXI data         %d", axi_data_width);
    endfunction: display

endclass: uart_config
