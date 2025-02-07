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

    /*
     * No provision for synchronizing lifecycle management is made here. This could lead
     * to race conditions, missed activity, incomplete scoreboards, etc. The canonical
     * way to deal with this is with objections (e.g., scoped global counters) but I
     * want to get something underway first before I introduce that.
     */

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

    // Override the log() and log_fatal() methods so we can provide hierarchy
    function void log(log_level_t level, string msg, string id = "");
        if (level >= this.current_log_level) begin
            super.log(level, this.get_full_hierarchical_name(), msg, id);
        end
    endfunction: log

    function void log_fatal(string msg, string id = "");
        super.log_fatal(this.get_full_hierarchical_name(), msg, id);
    endfunction: log_fatal

    function void log_info(string msg, string id = "");
        if (LOG_INFO >= this.current_log_level) begin
            logger::log(LOG_INFO, this.get_full_hierarchical_name(), msg, id);
        end
    endfunction: log_info
    
    function void log_warn(string msg, string id = "");
        if (LOG_WARN >= this.current_log_level) begin
            logger::log(LOG_WARN, this.get_full_hierarchical_name(), msg, id);
        end
    endfunction: log_warn

    function void log_debug(string msg, string id = "");
        if (LOG_DEBUG >= this.current_log_level) begin
            logger::log(LOG_DEBUG, this.get_full_hierarchical_name(), msg, id);
        end
    endfunction: log_debug

    function void log_error(string msg, string id = "");
        if (LOG_ERROR >= this.current_log_level) begin
            logger::log(LOG_ERROR, this.get_full_hierarchical_name(), msg, id);
        end
    endfunction: log_error

endclass: component_base

