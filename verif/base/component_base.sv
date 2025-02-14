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

    // Role to register components of this type as
    protected string role = "component";

    function new(string name = "component_base", component_base parent = null);
        super.new(name);
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
        this.current_log_level = default_log_level;
        this.current_phase = UNINITIALIZED;
    endfunction: new

    // Parent-child management --- {{{
    function void add_child(component_base child);
        if (this.children.exists(child.name)) begin
            // If the child exists in the hierarchy then something has gone very wrong
            log_fatal($sformatf("Child '%s' was already found in hierarchy", child.name));
        end else begin
            this.children[child.get_name()] = child;
        end
    endfunction: add_child

    function component_base get_parent();
        return this.parent;
    endfunction: get_parent

    function void print_hierarchy();
        $display("[%s]", this.name);
        foreach (this.children[i]) begin
            this.children[i].print_hierarchy();
        end
    endfunction: print_hierarchy

    // Overriding base class function because we actually have hierarchy (base class is flat)
    function string get_full_hierarchical_name();
        if (this.parent != null) begin
            return {this.parent.get_full_hierarchical_name(), ".", this.name};
        end
        return this.name;
    endfunction: get_full_hierarchical_name

    // }}}

    // Utilty methods --- {{{

    // Registers an object in the configuration database under ourselves
    function void register_object(string role, object_base obj);

        if (obj == null) begin
            log_fatal($sformatf("Attempted to register null object under '%s' with role '%s'.",
                        this.get_full_hierarchical_name(), role));
        end
        if (role == "") begin
            log_fatal($sformatf("Attempted to register object under '%s' with empty role.",
                        this.get_full_hierarchical_name()));
        end

        if (!config_db::set(this, role, obj)) begin
            log_fatal($sformatf("Could not register object '%s' under '%s' with role '%s'.",
                        obj.get_full_hierarchical_name(), this.get_full_hierarchical_name(), role));
        end
        return;

    endfunction: register_object

    // Registers a globally available object in the configuration database 
    function void register_global_object(string role, object_base obj);

        if (obj == null) begin
            log_fatal($sformatf("Attempted to register null object with global scope and role '%s'.", role));
        end
        if (role == "") begin
            log_fatal($sformatf("Attempted to register object under with global scope and empty role."));
        end

        if (!config_db::set(null, role, obj)) begin
            log_fatal($sformatf("Could not register object '%s' with global scope and role '%s'.",
                        obj.get_full_hierarchical_name(), role));
        end
        return;

    endfunction: register_global_object
    // }}}

    // Logging methods --- {{{

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
        logger::log(LOG_INFO, this.get_full_hierarchical_name(), msg, "");
        $fflush();
    endfunction: log_phase_entry

    function void log_phase_exit();
        string msg;
        msg = $sformatf("Leaving phase %s", this.current_phase.name());
        logger::log(LOG_INFO, this.get_full_hierarchical_name(), msg, "");
        $fflush();
    endfunction: log_phase_exit

    // }}}

    // Lifecycle methods --- {{{

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

        // Automatically register
        if (this.parent == null) begin
            log_info($sformatf("Skipping registration for top-level component: %s",
                                    this.get_full_hierarchical_name()));
        end else begin
            if (!config_db::set(this.parent, this.role, this)) begin
                log_fatal("Could not register configuration database ");
            end
        end

        // Now that the parent is registered, recursively call config_phase() on all
        // our children
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

        this.current_phase = BUILD;
        this.build_phase();

        this.current_phase = CONFIG;
        this.config_phase();

        this.current_phase = CONNECT;
        this.connect_phase();

        this.current_phase = PRE_RUN;
        this.pre_run_phase();

        this.current_phase = RUN;
        this.run_phase();

        this.current_phase = EXTRACT;
        this.extract_phase();

        this.current_phase = CHECK;
        this.check_phase();

        this.current_phase = FINAL;
        this.final_phase();

    endtask: run_lifecycle

    // }}}

endclass: component_base

