virtual class test_case_base extends component_base;

    function new(string name, component_base parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase();

        super.build_phase();
        if (this.get_parent() == null) begin
            config_db#(component_base)::set(null, "", "test_case", this);
        end

    endfunction: build_phase

endclass: test_case_base

