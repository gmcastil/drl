class uart_config #();

    string device;
    shortint unsigned axi_base_addr;
    shortint unsigned axi_base_mask;
    bit rx_enable;
    bit tx_enable;

    function new();
    endfunction: new

endclass: uart_config
