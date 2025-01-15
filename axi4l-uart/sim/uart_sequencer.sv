class uart_sequencer #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    mailbox #(axi4l_transaction#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    function new(mailbox #(axi4l_transaction#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue);
        this.txn_queue = new();
    endfunction: new

    task put_transaction(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn);
        this.txn_queue.put(txn);
        $display("[%0t] [SEQUENCER] Transaction added to the queue: addr=%0h, king=%s",
                    $time, txn.addr, txn.kind);
    endtask: put_transaction

endclass: uart_sequencer

