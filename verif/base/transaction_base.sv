virtual class transaction_base extends object_base;

    time created;
    time driver_start;
    time driver_end;

    bit response_required;

    function new(string name);
        super.new(name);
        this.created = 0;
        this.driver_start = 0;
        this.driver_end = 0;
        this.response_required = 1'b1;
    endfunction: new

    pure virtual function void display();

endclass: transaction_base
