// Similar to UVM, our configuration database is a type-parameterized static class, which allows us
// to store just about anything we want regardless of type.  
//
// First, there isn't really one configuration database, there is one configuration database *per
// parameterized type* and each of them is a static class unto itself. This means that the same
// scope and role can store different values, if the values are of a different types. Further, there
// is no mixing between values of different types - a role and scope of one type cannot be used to
// retrieve the value of a different type.  There is also no way for a lookup to search adjacent
// configuration databases.
//
// Changes to the configuration database:
// - Type-parameterized now so we can store and retrieve arbitrary objects.
// - Reverting to string scope and roles (removed typedefs)
// - Switching to "" for global lookups
// - Calls to set() and get() now require type-parameterization
// - Internally, only a single storage structure is required (strings instead of compenent_base
// types as the scope key allows this - essentially, the "" string is a new namespace).
// - Removed hierarchical lookups - users have to specify precisely the scope they wish to retrieve
// from.
// - Removing the remove() method since it isn't useful and UVM doesn't support it - I'm not chasing
// dynamic creation of verification components, so that sort of thing isnt' as useful.
// - Automatic self-registration needs to be moved to the component_base not object_base

class config_db#(type T);

    static string name;

    static T store [string][string];

    static log_level_t current_log_level ;

    static function void init(string init_name);
        name = init_name;
        current_log_level = logger::get_default_log_level();
        log_debug($sformatf("Initialized configuration database with name '%s'", name));
    endfunction: init

    static function void set(string scope, string role, T obj);

        // Ensure the role is valid (do not register empty roles or use them as wildcards)
        if (role == "") begin
            log_error($sformatf("Empty role not supported in scope \"%s\"", scope);
            return 0;
        end

        // Log if duplicate key was provided for this type, but we still overwrite
        if (store.exists(scope) && store[scope].exists(role)) begin
            log_debug($sformatf("Duplicate scope or role found for type %s", $typename(T)));
        end
        store[scope][role] = obj;
        return 1;

    endfunction: set

    static function bit get(string scope, string role, ref T obj);

        if (role == "") begin
            log_error($sformatf("Empty role not supported in scope \"%s\"", scope));
            return 0;
        end

        if (store.exists(scope) && store[scope].exists(role)) begin
            obj = store[scope][role];
            return 1;
        end else begin
            log_error($sformatf("Role not found in scope \"%s\" for type %s", scope, $typename(T)));
            return 0;
        end
    endfunction: get

    static function void dump();
        log_fatal("config_db::dump() not implemented yet)");
    endfunction: dump

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

