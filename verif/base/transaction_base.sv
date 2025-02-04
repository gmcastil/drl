virtual class transaction_base extends object_base;

    time timestamp;
    bit response_required;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
        this.response_required = 1'b1;
    endfunction: new

    pure virtual function void display();

endclass: transaction_base
