class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    uart_config cfg;
    component_state_t state;

    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;
    uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer;

    // Shared mailbox betwen driver and sequencer
    mailbox #(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
                    uart_config cfg);
        this.cfg = cfg;
        this.txn_queue = new();
        this.driver = new(axi4l_bfm, this.txn_queue);
        this.sequencer = new(this.txn_queue);
        this.state = UNINITIALIZED;
    endfunction: new

    task automatic init();
        if (this.state != UNINITIALIZED) begin
            $fatal("Environment already initialized or in an invalid state");
        end

        if (this.txn_queue == null) begin
            $fatal(0, "[ENV] Transaction mailbox is null. Initialization failed.");
        end else if (this.txn_queue.num() != 0) begin
            $fatal(0, "[ENV] Transaction mailbox non-empty during initialization.");
        end
        $display("[ENV] Mailbox created and initialized");

        // Driver setup and checks
        this.driver.initialize();

        // Sequencer setup and checks
        this.sequencer.initialize();

        state = INITIALIZED;
    endtask: init

    task automatic run();
        // AXI4-Lite driver runs in the background, pulling transactions out
        // of the shared communciation channel, placed there by the sequencer.
        fork begin
            this.driver.run();
        end join_none

    endtask: run

endclass: uart_env

