virtual class transaction_base extends component_base;

    function new(string name, component_base parent = null);
        super.new(name, parent);
    endfunction: new

    pure virtual function display();

endclass: transaction_base
