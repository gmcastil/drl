class object_base;

    string name;

    log_level_t current_log_level;

    function new(string name);
        this.name = name;
        this.current_log_level = LOG_MEDIUM;
    endfunction: new

    virtual function string get_name();
        return this.name;
    endfunction: get_name

    // Derived classes are expected to override this if they wish to support hierarchical references
    // (e.g., the component_base class)
    virtual function string get_full_name();
        return this.get_name();
    endfunction: get_full_name

    // Derived classes that have hierarchy (e.g., the component_base class) override this to
    // recursively set their children
    function void set_log_level(log_level_t level);
        this.current_log_level = level;
    endfunction: set_log_level

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction: get_log_level

endclass: object_base

