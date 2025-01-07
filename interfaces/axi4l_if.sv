interface axi4l_if #(
    parameter int   ADDR_WIDTH,
    parameter int   DATA_WIDTH
) (
    input   wire    aclk,
    input   wire    aresetn
);

    // Write Address Channel
    wire  [ADDR_WIDTH-1:0]      awaddr;
    wire                        awvalid;
    wire                        awready;
    wire                        awprot;

    // Write Data Channel
    wire  [DATA_WIDTH-1:0]      wdata;
    wire  [(DATA_WIDTH/8)-1:0]  wstrb;
    wire                        wvalid;
    wire                        wready;

    // Write Response Channel
    wire  [1:0]                 bresp;
    wire                        bvalid;
    wire                        bready;

    // Read Address Channel
    wire  [ADDR_WIDTH-1:0]      araddr;
    wire                        arvalid;
    wire                        arready;
    wire                        arprot;

    // Read Data Channel
    wire  [DATA_WIDTH-1:0]      rdata;
    wire  [1:0]                 rresp;
    wire                        rvalid;
    wire                        rready;

endinterface : axi4l_if


