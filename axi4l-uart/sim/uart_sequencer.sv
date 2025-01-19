class uart_sequencer;

    mailbox #(axi4l_transaction) txn_queue;

    function new(mailbox #(axi4l_transaction) txn_queue);
        this.txn_queue = new();
    endfunction: new

    task put_transaction(axi4l_transaction txn);
        this.txn_queue.put(txn);
        $display("[%0t] [SEQUENCER] Transaction added to the queue: addr=%0h, king=%s",
                    $time, txn.addr, txn.kind);
    endtask: put_transaction

endclass: uart_sequencer

