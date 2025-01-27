package axi4l_pkg;

    import common_pkg::*;
    import base_pkg::*;

    // AXI4-Lite read and write response types
    typedef enum logic [1:0] {
        RESP_OKAY       = 2'b00,    // Transaction completed successfully
        RESP_EXOKAY     = 2'b01,    // Exclusvie access successful
        RESP_SLVERR     = 2'b10,    // Slave error
        RESP_DECERR     = 2'b11     // Decode error
    } axi4l_resp_t;

    typedef enum {
        READ,
        WRITE8,
        WRITE16,
        WRITE32,
        WRITE64
    } axi4l_txn_t;

    virtual class axi4l_bfm_base #(
        parameter int ADDR_WIDTH,
        parameter int DATA_WIDTH
    );

        pure virtual task automatic reset(int unsigned count);
        pure virtual task automatic read(input logic [ADDR_WIDTH-1:0] rd_addr, output logic [DATA_WIDTH-1:0] rd_data, axi4l_resp_t rd_resp);
        pure virtual task automatic write(input logic [ADDR_WIDTH-1:0] wr_addr, input logic [DATA_WIDTH-1:0] wr_data, input logic [(DATA_WIDTH/8)-1:0] wr_be, output axi4l_resp_t wr_resp);
        pure virtual function void display();

    endclass: axi4l_bfm_base

`include "axi4l_driver.sv"

endpackage: axi4l_pkg


