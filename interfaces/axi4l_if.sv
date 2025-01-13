interface axi4l_if #(
    parameter int   ADDR_WIDTH,
    parameter int   DATA_WIDTH
) (
    input   logic   aclk,
    input   logic   aresetn
);

    import axi4l_pkg::*;

    // Write Address Channel
    logic [ADDR_WIDTH-1:0]      awaddr;
    logic                       awvalid;
    logic                       awready;
    logic [2:0]                 awprot;

    // Write Data Channel
    logic [DATA_WIDTH-1:0]      wdata;
    logic [(DATA_WIDTH/8)-1:0]  wstrb;
    logic                       wvalid;
    logic                       wready;

    // Write Response Channel
    logic [1:0]                 bresp;
    logic                       bvalid;
    logic                       bready;

    // Read Address Channel
    logic [ADDR_WIDTH-1:0]      araddr;
    logic                       arvalid;
    logic                       arready;
    logic [2:0]                 arprot;

    // Read Data Channel
    logic [DATA_WIDTH-1:0]      rdata;
    logic [1:0]                 rresp;
    logic                       rvalid;
    logic                       rready;

    clocking cb_master @(posedge aclk);
        output awaddr, wdata, wstrb, araddr, awvalid, wvalid, awprot, arvalid, rready, arprot, bready;
        input awready, wready, arready, rvalid, bvalid, rdata, rresp, bresp;
    endclocking

    clocking cb_slave @(posedge aclk);
        input awaddr, wdata, wstrb, araddr, awvalid, wvalid, awprot, arvalid, rready, arprot, bready;
        output awready, wready, arready, rvalid, bvalid;
        // These are made inout so that they can be capture from the slave domain as outputs (recall
        // that per LRM, outputs of clocking blocks have no scheduling semantics, but inouts do.
        inout rdata, rresp, bresp;
    endclocking

    /*
     * There are mixed blocking and non-blocking assignments in the read and write tasks for this
     * interface which is quite intentional. 
     */

    // Perform an AXI4-Lite read transaction
    task automatic read(input logic [ADDR_WIDTH-1:0] rd_addr, output logic [DATA_WIDTH-1:0] rd_data, output axi4l_resp_t rd_resp);

        event raddr_done;

        // Background two processes, one to wait for the address phase to be complete and signal
        // to the other to wait for the data phase to be complete
        fork
            // Read address accepted phase
            begin
                // Assert that we have a valid address and block until ready and valid are true
                cb_master.araddr <= rd_addr;
                cb_master.arvalid <= 1'b1;
                @(cb_slave.arready);
                // Invalidate the address and zero it out (could also put some noise on it here)
                cb_master.arvalid <= 1'b0;
                cb_master.araddr <= 'X;
                ->raddr_done;
            end

            // Read data accepted phase
            begin
                // Once the event has fired, we can capture the data
                @raddr_done;

                // Assert that we are ready for data and block until valid and ready are true
                cb_master.rready <= 1'b1;
                @(cb_slave.rvalid);
                cb_master.rready <= 1'b0;
                rd_data = cb_slave.rdata;
                rd_resp = axi4l_resp_t'(cb_slave.rresp);
            end
        // Require that both of these tasks complete before rejoining the main thread
        join
        return;

    endtask: read

    // Perform an AXI4-Lite write transaction
    task automatic write(input logic [ADDR_WIDTH-1:0] wr_addr, input logic [DATA_WIDTH-1:0] wr_data,
                            input logic [(DATA_WIDTH/8)-1:0] wr_be, output axi4l_resp_t wr_resp);

        bit wdata_done = 1'b0;
        bit awaddr_done = 1'b0;

        fork
            // Write address accepted phase
            begin
                cb_master.awaddr <= wr_addr;
                cb_master.awvalid <= 1'b1;
                @(cb_slave.awready);
                // Invalidate the address and zero it out (could also put some noise on it here)
                cb_master.awvalid <= 1'b0;
                cb_master.awaddr <= 'X;

                awaddr_done = 1'b1;
            end
            // Write data accepted phase
            begin
                cb_master.wdata <= wr_data;
                cb_master.wstrb <= wr_be;
                cb_master.wvalid <= 1'b1;
                @(cb_slave.wready);
                // Invalidate the data bus 
                cb_master.wvalid <= 1'b0;
                cb_master.wdata <= 'X;
                cb_master.wstrb <= 'X;
                
                wdata_done = 1'b1;
            end
        join

        // Wait for both phases to complete
        wait(awaddr_done && wdata_done);

        // Response phase
        cb_master.bready <= 1'b1;
        @(cb_slave.bvalid);
        cb_master.bready <= 1'b0;
        wr_resp = axi4l_resp_t'(cb_slave.bresp);
        return;

    endtask: write

    function void display;
        $display("AXI_ADDR_WIDTH = %d", ADDR_WIDTH);
        $display("AXI_DATA_WIDTH = %d", DATA_WIDTH);
    endfunction: display

endinterface: axi4l_if


