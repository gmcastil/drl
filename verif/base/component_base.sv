class component_base;

    string name;
    component_base parent;
    typedef component_base children_t [$];
    children_t children;

    function new(string name, component_base parent = null);
        this.name = name;
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
    endfunction: new

    virtual task build_phase();
        $display("[%s] build_phase called", name);
    endtask: build_phase

    virtual task connect_phase();
        $display("[%s] connect_phase called", name);
    endtask: connect_phase

    virtual task run_phase();
        $display("[%s] run_phase called", name);
    endtask: run_phase

    virtual task final_phase();
        $display("[%s] final_phase called", name);
    endtask: final_phase

    function void add_child(component_base child);
        this.children.push_back(child);
    endfunction: add_child

    function children_t get_children();
        return this.children;
    endfunction: get_children

    virtual task print_hierarchy();
        $display("[%s]", this.name);
        foreach (this.children[i]) begin
            this.children[i].print_hierarchy();
        end
    endtask: print_hierarchy

endclass: component_base

