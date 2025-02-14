class config_db;

    static string name;

    typedef component_base scope_t;
    typedef string role_t;

    // The configuration database stores references to components and other objects derived from
    // the base class. Each object is stored using a role-based key, ensuring that components can
    // retrieve the correct instance without relying on explicit hierarchical names.
    //
    // There are two data structures used for storage:
    // 1. `store [scope_t][role_t]` - Hierarchical storage:
    //    - Objects are registered under their parent component (scope).
    //    - Lookups traverse up the hierarchy if the role is not found at the initial scope.
    //
    // 2. `global_store [role_t]` - Global storage:
    //    - Used for system-wide objects (e.g., obj_mgr, global settings).
    //    - These objects are accessible from anywhere using a `null` scope in `get()`.
    //
    // The `set()` function registers objects into the correct storage based on scope,
    // while `get()` first checks global_store before searching up the hierarchy.
    static object_base store [scope_t][role_t];
    static object_base global_store [role_t];

    static log_level_t current_log_level ;

    static function void init(string init_name);
        name = init_name;
        current_log_level = logger::get_default_log_level();
        log_debug($sformatf("Initialized configuration database with name '%s'", name));
    endfunction: init

    static function bit set(scope_t scope, role_t role, object_base obj);
        // Ensure the role is valid (cannot be empty)
        if (role == "") begin
            log_fatal("Objects cannot be registered with empty roles");
            return 0;
        end

        // Global scope
        if (scope == null) begin
            if (global_store.exists(role)) begin
                log_error($sformatf("Registration failed. Role '%s' already in global scope", role));
                return 0;
            end else begin
                global_store[role] = obj;
                log_debug($sformatf("Registered role '%s' in global scope", role));
                return 1;
            end
        end

        // Store in provided scope
        if (store.exists(scope) && store[scope].exists(role)) begin
            log_error($sformatf("Role '%s' already exists in configuration database", role));
            return 0;
        end else begin
            store[scope][role] = obj;
            log_debug($sformatf("Registered role '%s' in scope: %s", 
                                    role, scope.get_full_hierarchical_name()));
            return 1;
        end

    endfunction: set

    static function bit get(scope_t scope, role_t role, ref object_base obj);
        // Ensure the role is valid (cannot be empty)
        if (role == "") begin
            log_fatal("Objects cannot be registered with empty roles");
            return 0;
        end

        // Global scope
        if (scope == null) begin
            if (global_store.exists(role)) begin
                obj = global_store[role];
                log_debug($sformatf("Found role '%s' in global scope", role));
                return 1;
            end else begin
                log_error($sformatf("Lookup failed. Role '%s' not found in global scope.", role));
                return 0;
            end
        end

        // Search the given scope and if not found, climb up the hierarchy looking to see if the
        // parents registered the component.
        while (scope != null) begin
            log_debug($sformatf("Searching for role '%s' in scope: %s",
                                    role, scope.get_full_hierarchical_name()));
            if (store.exists(scope) && store[scope].exists(role)) begin
                obj = store[scope][role];
                log_debug($sformatf("Found role '%s' in scope: %s", 
                                        role, scope.get_full_hierarchical_name()));
                return 1;
            end else begin
                scope = scope.get_parent();
            end
        end

        log_error($sformatf("Lookup failed. Role '%s' not found in hierarchy.", role));
        return 0;

    endfunction: get

    static function bit remove(scope_t scope, role_t role);
        log_fatal("config_db::remove() not implemented yet)");
    endfunction: remove

    static function void list();
        log_fatal("config_db::list() not implemented yet)");
    endfunction: list

    static function void log(log_level_t level, string msg, string id = "");
        if (level > current_log_level) begin
            return;
        end
        logger::log(level, name, msg, id);
    endfunction: log

    static function void log_info(string msg, string id = "");
        log(LOG_INFO, msg, id);
    endfunction: log_info

    static function void log_warn(string msg, string id = "");
        log(LOG_WARN, msg, id);
    endfunction: log_warn

    static function void log_debug(string msg, string id = "");
        log(LOG_DEBUG, msg, id);
    endfunction: log_debug

    static function void log_error(string msg, string id = "");
        log(LOG_ERROR, msg, id);
    endfunction: log_error

    // Logs a fatal message with optional ID and then exits the simulation at that point
    static function void log_fatal(string msg, string id = "");
        logger::log(LOG_FATAL, name, msg, id);
        // The $stacktrace task (can also be called as a function) was only added to the language in
        // 2023 but has been implemented by Questa since at least 2013. To try to maintain some sort of
        // compatibility, this can be turned off at runtime if needed
`ifndef NO_STACKTRACE_SUPPORT
        $stacktrace;
`endif
        $fflush();
        $fatal(1);
    endfunction: log_fatal

endclass: config_db

