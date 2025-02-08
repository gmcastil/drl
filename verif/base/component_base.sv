virtual class component_base extends object_base;

    component_base parent;
    component_base children [string];

    function new(string name = "component_base", component_base parent = null);
        super.new(name);
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
        this.current_log_level = default_log_level;
    endfunction: new

    /* Parent-child management and context functions */
    function void add_child(component_base child);
        if (this.children.exists(child.name)) begin
            // If the child exists in the hierarchy then something has gone very wrong
            log(LOG_ERROR, $sformatf("Child '%s' was already found in hierarchy", child.name));
        end else begin
            this.children[child.name] = child;
        end
    endfunction: add_child

    virtual task print_hierarchy();
        $display("[%s]", this.name);
        foreach (this.children[i]) begin
            this.children[i].print_hierarchy();
        end
    endtask: print_hierarchy

    function string get_full_hierarchical_name();
        if (this.parent != null) begin
            return {this.parent.get_full_hierarchical_name(), ".", this.name};
        end
        return this.name;
    endfunction: get_full_hierarchical_name

    virtual task build_phase();
        log_debug("Started component_base build phase", "SUPER");
        foreach (this.children[i]) begin
            this.children[i].build_phase();
        end
    endtask: build_phase

    virtual task connect_phase();
        log_debug("Started component_base connect phase", "SUPER");
        foreach (this.children[i]) begin
            this.children[i].connect_phase();
        end
    endtask: connect_phase

    virtual task run_phase();
        log_debug("Started component_base run phase", "SUPER");
    endtask: run_phase

    virtual task final_phase();
        log_debug("Started component_base final phase", "SUPER");
        foreach (this.children[i]) begin
            this.children[i].final_phase();
        end
    endtask: final_phase

    // Override this so we can set the log levels of our children
    virtual function void set_log_level(log_level_t level);
        log_info($sformatf("Setting log level to %s for %s",
            level.name(), this.get_full_hierarchical_name()));
        this.current_log_level = level;
        foreach (this.children[i]) begin
            this.children[i].set_log_level(level);
        end
    endfunction: set_log_level

endclass: component_base

