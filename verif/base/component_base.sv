virtual class component_base;

    string name;
    component_base parent;
    typedef component_base children_t [$];
    children_t children;

    log_level_t current_log_level = default_log_level;

    function new(string name = "component_base", component_base parent = null);
        this.name = name;
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
        this.current_log_level = default_log_level;
    endfunction: new

    /*
     * No provision for synchronizing lifecycle management is made here. This could lead
     * to race conditions, missed activity, incomplete scoreboards, etc. The canonical
     * way to deal with this is with objections (e.g., scoped global counters) but I
     * want to get something underway first before I introduce that.
     */

    virtual task build_phase();
        log(LOG_DEBUG, "Component base build phase");
    endtask: build_phase

    virtual task connect_phase();
        log(LOG_DEBUG, "Component base connect phase");
    endtask: connect_phase

    virtual task run_phase();
        log(LOG_DEBUG, "Component base run phase");
    endtask: run_phase

    virtual task final_phase();
        log(LOG_DEBUG, "Component base final phase");
    endtask: final_phase

    /* 
     * There's a potential to possibly introduce recursive lifecycle management here
     * but we'll save it for later once it become obviously a thing to add.
     */

    /* Hierarchy might start to matter latter if I start introducing multiple envs */

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

    virtual function string get_name();
        return this.name;
    endfunction: get_name

    function void set_log_level(log_level_t level);
        this.current_log_level = level;
    endfunction: set_log_level

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction: get_log_level

    function void log(log_level_t level, string msg);
        if (level >= this.current_log_level) begin
            $display("[%0t] [%s] [%s] %s", $time, this.name, level.name(), msg);
        end
    endfunction: log

endclass: component_base

