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
        output awready, wready, arready, rvalid, bvalid, rdata, rresp, bresp;
    endclocking

    modport MASTER (
        input aclk, aresetn,
        clocking cb_master
    );

    modport SLAVE (
        input aclk, aresetn,
        clocking cb_slave
    );

    // Perform an AXI4-Lite read transaction
    task automatic read(input logic [ADDR_WIDTH-1:0] rd_addr, output logic [DATA_WIDTH-1:0] rd_data, output axi4l_resp_t rd_resp);

        event raddr_done;

        if (aresetn == 1'b0) begin
            $display("Read ignored while in reset");
            return;
        end

        // Background two processes, one to wait for the address phase to be complete and signal
        // to the other to wait for the data phase to be complete
        fork
            // Read address accepted phase
            begin
                // Assert that we have a valid address and block until ready and valid are true
                araddr = rd_addr;
                arvalid = 1'b1;
                @(cb_slave.arready);
                // Invalidate the address and zero it out (could also put some noise on it here)
                arvalid = 1'b0;
                araddr = 'X;
                ->raddr_done;
            end

            // Read data accepted phase
            begin
                // Once the event has fired, we can capture the data
                @raddr_done;

                // Assert that we are ready for data and block until valid and ready are true
                rready = 1'b1;
                @(cb_slave.rvalid);
                rd_data = cb_slave.rdata;
                rd_resp = axi4l_resp_t'(rresp);
                rready = 1'b0;
            end
        // Require that both of these tasks complete before rejoining the main thread
        join
        return;

    endtask: read

    task automatic write(input logic [ADDR_WIDTH-1:0] wr_addr, input logic [DATA_WIDTH-1:0] wr_data,
                            input logic [(DATA_WIDTH/8)-1:0] wr_be, output axi4l_resp_t wr_resp);

        bit wdata_done = 1'b0;
        bit awaddr_done = 1'b0;

        fork
            // Write address accepted phase
            begin
                awaddr = wr_addr;
                awvalid = 1'b1;
                @(cb_slave.awready);
                // Invalidate the address and zero it out (could also put some noise on it here)
                awvalid = 1'b0;
                awaddr = 'X;
                awaddr_done = 1'b1;
            end
            // Write data accepted phase
            begin
                wdata = wr_data;
                wstrb = wr_be;
                wvalid = 1'b1;
                @(cb_slave.wready);
                // Invalidate the data bus 
                wvalid = 1'b0;
                wdata = 'X;
                wstrb = 'X;
                wdata_done = 1'b1;
            end
        join

        // Wait for both phases to complete
        wait(awaddr_done && wdata_done);

        // Response phase
        bready = 1'b1;
        @(cb_slave.bvalid);
        bready = 1'b0;
        wr_resp = axi4l_resp_t'(bresp);
        return;

    endtask: write

endinterface: axi4l_if


