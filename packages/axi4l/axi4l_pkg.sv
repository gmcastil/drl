package axi4l_pkg;

    // AXI4-Lite read and write response types
    typedef enum logic [1:0] {
        RESP_OKAY       = 2'b00,    // Transaction completed successfully
        RESP_EXOKAY     = 2'b01,    // Exclusvie access successful
        RESP_SLVERR     = 2'b10,    // Slave error
        RESP_DECERR     = 2'b11     // Decode error
    } axi4l_resp_t;

    typedef enum {READ, WRITE8, WRITE16, WRITE32, WRITE64} axi4l_txn_t;

`include "axi4l_transaction.sv"
`include "axi4l_driver.sv"

endpackage: axi4l_pkg

