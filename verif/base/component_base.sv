virtual class component_base;

    string name;
    component_base parent;
    component_base children [string];

    log_level_t current_log_level = default_log_level;

    function new(string name = "component_base", component_base parent = null);
        this.name = name;
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
            log(LOG_ERROR, "HIERARCHY", $sformatf("Child '%s' was already found in hierarchy", child.name));
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

    virtual function string get_name();
        return this.name;
    endfunction: get_name

    function string get_full_hierarchical_name();
        if (this.parent != null) begin
            return {this.parent.get_full_hierarchical_name(), ".", this.name};
        end
        return this.name;
    endfunction: get_full_hierarchical_name

    /*
     * No provision for synchronizing lifecycle management is made here. This could lead
     * to race conditions, missed activity, incomplete scoreboards, etc. The canonical
     * way to deal with this is with objections (e.g., scoped global counters) but I
     * want to get something underway first before I introduce that.
     */

    virtual task build_phase();
        log(LOG_DEBUG, "Component base build phase");
        foreach (this.children[i]) begin
            this.children[i].build_phase();
        end
    endtask: build_phase

    virtual task connect_phase();
        log(LOG_DEBUG, "Component base connect phase");
        foreach (this.children[i]) begin
            this.children[i].connect_phase();
        end
    endtask: connect_phase

    virtual task run_phase();
        log(LOG_DEBUG, "Component base run phase");
        foreach (this.children[i]) begin
            this.children[i].run_phase();
        end
    endtask: run_phase

    virtual task final_phase();
        log(LOG_DEBUG, "Component base final phase");
        foreach (this.children[i]) begin
            this.children[i].final_phase();
        end
    endtask: final_phase

    function void set_log_level(log_level_t level);
        this.current_log_level = level;
    endfunction: set_log_level

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction: get_log_level

    function void log(log_level_t level, string msg, string id = "");
        string level_name; 
        string msg_fmt;
        if (level >= this.current_log_level) begin
            // UVM like log messages, with optional ID field
            if (id == "") begin
                msg_fmt = "%s @ %0t: (%s) %s";
            end else begin
                msg_fmt = "%s @ %0t: (%s) [%s] %s";
            end
            level_name = level.name();
            $display(msg_fmt,
                        level_name.substr(4, level_name.len()-1),
                        $time, this.get_full_hierarchical_name(), id, msg);
        end
    endfunction: log

endclass: component_base

