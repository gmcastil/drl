virtual class transaction_base extends object_base;

    time timestamp;

    function new(string name);
        super.new(name);
        this.timestamp = $time;
    endfunction: new

    pure virtual function void display();

endclass: transaction_base
