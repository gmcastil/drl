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
    task read(input logic [ADDR_WIDTH-1:0] rd_addr, output logic [DATA_WIDTH-1:0] rd_data, output axi4l_resp_t rd_resp);

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
                @(cb_master.arready);
                arvalid = 1'b0;
                ->raddr_done;
            end
            begin
                // Once the event has fired, we can capture the data
                @raddr_done;

                // Assert that we are ready for data and block until valid and ready are true
                rready = 1'b1;
                @(cb_master.rvalid);
                rd_data = rdata;
                rd_resp = axi4l_resp_t'(rresp);
                rready = 1'b0;
            end
        // Require that both of these tasks complete before rejoining the main thread
        join
        return;

    endtask

endinterface: axi4l_if


