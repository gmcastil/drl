class axi4l_driver #(parameter int AXI_ADDR_WIDTH, parameter int AXI_DATA_WIDTH)
    extends driver_base;

    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;
    protected mailbox #(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    function new(string name = "",
                    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
                    component_base parent = null);
        super.new(name, parent);
        if (axi4l_bfm == null) begin
            log(LOG_ERROR, "AXI4-Lite BFM is null.", "INIT");
            $fatal(1);
        end else begin
            this.axi4l_bfm = axi4l_bfm;
            log(LOG_INFO, "Created AXI4-Lite driver");
        end
    endfunction: new

    task run_phase();
        super.run_phase();
        log(LOG_INFO, "Driver run phase");
        forever begin
        end
    endtask: run_phase

    function void set_mailbox(mailbox #(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) mbox);
        if (mbox == null) begin
            log(LOG_ERROR, "Cannot set driver mailbox. Null pointer received.");
            $fatal(1);
        end else begin
            this.txn_queue = mbox;
        end
    endfunction: set_mailbox

    task process_transaction(transaction_base txn);
        $fatal("[%s] process_transaction() must be overridden in a derived class.", name);
    endtask: process_transaction

endclass: axi4l_driver
    

    /* function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, */
    /*                 mailbox #(axi4l_transaction#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue); */
    /*     this.txn_queue = txn_queue; */
    /*     if (this.txn_queue == null) begin */
    /*         $fatal(0, "Could not create AXI4L driver mailbox"); */
    /*     end */
    /*     this.state = UNINITIALIZED; */
    /* endfunction: new */

    /* task automatic init(); */
    /*     // Check that the communication channel exists and is empty before we start advertising we */
    /*     // can accept transactions */
    /*     if (this.txn_queue == null) begin */
    /*         $fatal(0, "[ENV] Transaction mailbox is null. Initialization failed."); */
    /*     end else if (this.txn_queue.num() != 0) begin */
    /*         $fatal(0, "[ENV] Transaction mailbox non-empty during initialization."); */
    /*     end */

    /*     // Reset the AXI4-Lite BFM */
    /*     this.axi4l_bfm.reset(10); */
    /*     this.state = INITIALIZED; */
    /* endtask: init */

    /* // Pull transactions from the mailbox and process them in the order they arrive */
    /* task automatic run(); */

    /*     logic [7:0] byte_enable; */
    /*     logic [AXI_DATA_WIDTH-1:0] aligned_data; */
    /*     axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn; */

    /*     $display("[DRIVER] Started AXI4 Lite driver"); */
    /*     $fflush; */

    /*     forever begin */
    /*         this.txn_queue.get(txn); */
    /*         case (txn.kind) */
    /*             READ:       begin this.axi4l_bfm.read(txn.addr, txn.data, txn.resp); end */
    /*             WRITE8:     begin write8(txn.addr, txn.data[7:0], txn.position, txn.resp); end */
    /*             WRITE16:    begin write16(txn.addr, txn.data[15:0], txn.position, txn.resp); end */
    /*             WRITE32:    begin write32(txn.addr, txn.data[31:0], txn.position, txn.resp); end */
    /*             WRITE64:    begin write64(txn.addr, txn.data[63:0], txn.resp); end */
    /*             default:    begin $fatal("Unsupported operation type: %d", txn.kind); end */
    /*         endcase */
    /*         txn.display(); */
    /*     end */

    /* endtask: run */

    /* task automatic write8(logic [AXI_ADDR_WIDTH-1:0] addr, logic [7:0] data, int position, axi4l_resp_t resp); */
    /*     logic [AXI_DATA_WIDTH-1:0] aligned_data; */
    /*     logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable; */

    /*     assert(position < (AXI_DATA_WIDTH/8)) */
    /*         else $fatal(0, "Position out of range"); */

    /*     aligned_data = data << (position * 8); */
    /*     byte_enable = 1'b1 << position; */

    /*     this.axi4l_bfm.write(addr, aligned_data, byte_enable, resp); */
    /* endtask: write8 */

    /* task automatic write16(logic [AXI_ADDR_WIDTH-1:0] addr, logic [15:0] data, int position, axi4l_resp_t resp); */
    /*     logic [AXI_DATA_WIDTH-1:0] aligned_data; */
    /*     logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable; */

    /*     assert(position < (AXI_DATA_WIDTH/8) && position % 2 == 0) */
    /*         else $fatal(0, "Position out of range or position unaligned"); */

    /*     aligned_data = data << (position * 8); */
    /*     byte_enable = 2'b11 << position; */
    /*     this.axi4l_bfm.write(addr, aligned_data, byte_enable, resp); */
    /* endtask: write16 */

    /* task automatic write32(logic [AXI_ADDR_WIDTH-1:0] addr, logic [31:0] data, int position, axi4l_resp_t resp); */
    /*     logic [AXI_DATA_WIDTH-1:0] aligned_data; */
    /*     logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable; */

    /*     assert(position < (AXI_DATA_WIDTH/8) && position % 4 == 0) */
    /*         else $fatal(0, "Position out of range or position unaligned"); */

    /*     aligned_data = data << (position * 8); */
    /*     byte_enable = 4'b1111 << position; */
    /*     this.axi4l_bfm.write(addr, aligned_data, byte_enable, resp); */
    /* endtask: write32 */

    /* task automatic write64(logic [AXI_ADDR_WIDTH-1:0] addr, logic [63:0] data, axi4l_resp_t resp); */
    /*     logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable; */

    /*     assert(AXI_DATA_WIDTH == 64) */
    /*         else $fatal(0, "Data bus width unsupported"); */

    /*     byte_enable = 8'hFF; */
    /*     this.axi4l_bfm.write(addr, data, byte_enable, resp); */
    /* endtask: write64 */

    /* function automatic void display; */
    /*     $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH); */
    /*     $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH); */
    /* endfunction: display */

/* endclass: axi4l_driver */
