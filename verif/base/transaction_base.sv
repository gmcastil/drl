virtual class transaction_base extends component_base;

    string name;
    time timestamp;

    function new(string name);
        this.name = name;
        this.timestamp = $time;
    endfunction: new

    pure virtual function void display();
    // pure virtual function transaction_base clone();
    // pure virtual function void compare();

endclass: transaction_base
