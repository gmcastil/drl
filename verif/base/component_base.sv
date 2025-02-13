virtual class component_base extends object_base;

    // Enable phase aware logging and messages
    typedef enum {
        UNINITIALIZED,
        BUILD,
        CONFIG,
        CONNECT,
        PRE_RUN,
        RUN,
        EXTRACT,
        CHECK,
        FINAL
    } phase_t;

    phase_t current_phase;

    component_base parent;
    component_base children [string];

    function new(string name = "component_base", component_base parent = null);
        super.new(name);
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
        this.current_log_level = default_log_level;
        this.current_phase = UNINITIALIZED;
    endfunction: new

    /* Parent-child management and context functions */
    function void add_child(component_base child);
        if (this.children.exists(child.name)) begin
            // If the child exists in the hierarchy then something has gone very wrong
            log_fatal($sformatf("Child '%s' was already found in hierarchy", child.name));
        end else begin
            this.children[child.get_name()] = child;
        end
    endfunction: add_child

    task print_hierarchy();
        $display("[%s]", this.name);
        foreach (this.children[i]) begin
            this.children[i].print_hierarchy();
        end
    endtask: print_hierarchy

    // Overriding base class function because we actually have hierarchy (base class is flat)
    function string get_full_hierarchical_name();
        if (this.parent != null) begin
            return {this.parent.get_full_hierarchical_name(), ".", this.name};
        end
        return this.name;
    endfunction: get_full_hierarchical_name

    // Overriding base class function so we can set the log levels of our children
    function void set_log_level(log_level_t level);
        this.current_log_level = level;
        foreach (this.children[i]) begin
            this.children[i].set_log_level(level);
        end
    endfunction: set_log_level

    function void log_phase_entry();
        string msg;
        msg = $sformatf("Entering phase %s", this.current_phase.name());
        logger::log(LOG_INFO, this.get_full_hierarchical_name(), msg);
        $fflush();
    endfunction log_phase_entry

    function void log_phase_exit();
        string msg;
        msg = $sformatf("Leaving phase %s", this.current_phase.name());
        logger::log(LOG_INFO, this.get_full_hierarchical_name(), msg);
        $fflush();
    endfunction log_phase_exit

    // Recursive lifecycle executiong - each phase in component_base should execute its own logic
    // first and then call super.<phase> to ensure parent logic runs.
    //
    // Derived classes should call super.<phase> and then their own logic.
    virtual function void build_phase();
        this.current_phase = BUILD;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].build_phase();
        end
    endfunction: build_phase

    virtual function void config_phase();
        this.current_phase = CONFIG;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].config_phase();
        end
    endfunction: config_phase

    virtual function void connect_phase();
        this.current_phase = CONNECT;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].connect_phase();
        end
    endfunction: connect_phase

    virtual function void pre_run_phase();
        this.current_phase = PRE_RUN;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].pre_run_phase();
        end
    endfunction: pre_run_phase

    virtual task run_phase();
        this.current_phase = RUN;
        log_phase_entry();
    endtask: run_phase

    virtual function void extract_phase();
        this.current_phase = EXTRACT;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].extract_phase();
        end
    endfunction: extract_phase

    virtual function void check_phase();
        this.current_phase = CHECK;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].check_phase();
        end
    endfunction: check_phase

    virtual function void final_phase();
        this.current_phase = FINAL;
        log_phase_entry();
        foreach (this.children[i]) begin
            this.children[i].final_phase();
        end
    endfunction: final_phase

    task run_lifecycle();

        this.build_phase();
        this.config_phase();
        this.connect_phase();
        this.pre_run_phase();
        this.run_phase();
        this.extract_phase();
        this.check_phase();
        this.final_phase();

    endtask: run_lifecycle

endclass: component_base

