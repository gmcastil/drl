virtual class transaction_base extends object_base;

    function new(string name);
        super.new(name);
    endfunction: new

    pure virtual function void display();

endclass: transaction_base
