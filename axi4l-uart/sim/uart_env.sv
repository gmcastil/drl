/* class mailbox_component #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) */
/*     extends component_base; */

/*     function new( */

/* endclass: mailbox_component */

class uart_env #(parameter int AXI_ADDR_WIDTH, parameter int AXI_DATA_WIDTH)
    extends env_base;

    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;
    uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer;
    mailbox #(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    /*
     * For now create a mailbox and manually connect it to the driver and sequencer.
     * Later, we will want to create a mailbox_component or something of the sort that
     * derives from component_base, register it with the config_db and then during the
     * connect_phase both the driver and the sequencer will look it up and then connect
     * it themselves. For now, I want the driver and sequencer able to communicate and
     * I want to see transactions.
     */

    function new(string name,
                    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
                    component_base parent = null);

        super.new(name, parent);
        // AXI4-Lite driver
        this.driver = new("axi4l_driver", axi4l_bfm, this);
        // UART sequencer
        this.sequencer = new("uart_sequencer", this);
    endfunction: new

    task build_phase();
        super.build_phase();
        // TODO Encapsulate this as a mailbox_component and then create
        // it here, register it in the config_db so that the driver and
        // sequencers can retrieve it in their connect phases
        this.txn_queue = new();
        if (this.txn_queue == null) begin
            log(LOG_FATAL, "Could not create transaction queue");
        end else begin
            log(LOG_INFO, "Created transaction queue");
        end
    endtask: build_phase

    task connect_phase();
        super.connect_phase();
        this.driver.set_mailbox(this.txn_queue);
        this.sequencer.set_mailbox(this.txn_queue);
    endtask: connect_phase

endclass: uart_env
