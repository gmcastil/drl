class config_db;

    // The configuration database can store component references as well as sequences,
    // transactions, and anything else that derives from this lowest base class
    static object_base store [string];

    static string name;

    /* NOTE For now, use * as the scope when setting and retrieving keys for wildcards. In the
     * future refactor this to actually use wildcards so that items can be stored with the scope
     * '*' and then retrieved with whatever scope is desired.  For example, set("*", foo, bar) and
     * then retrieved with get("baz", foo, blar).  As is, you have to retrieve it with * as the
     * scope.
     */

    static log_level_t current_log_level ;

    static function void init(string name);
        name = name;
        current_log_level = logger::get_default_log_level();
        log_debug($sformatf("Initialized configuration database with name '%s'", name));
    endfunction: init

    static function bit set(string scope, string key, object_base value);
        string full_key;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            log_error($sformatf("Key '%s' was already found in configuration database", full_key));
            return 0;
        end else begin
            store[full_key] = value;
            log_debug($sformatf("Registered %s in configuration database with key %s", value.get_name(), full_key));
            return 1;
        end
    endfunction: set

    static function bit get(string scope, string key, ref object_base value);
        string full_key;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            value = store[full_key];
            log_debug($sformatf("Retrieved %s from configuration database with key %s", value.get_name(), full_key));
            return 1;
        end else begin
            log_error($sformatf("Key '%s' not found in configuration database", full_key));
            return 0;
        end
    endfunction: get

    static function bit remove(string scope, string key);
        string full_key;
        object_base value;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            value = store[full_key];
            store.delete(full_key);
            log_debug($sformatf("Deleted %s from configuration database with key %s", value.get_name(), full_key));
            return 1;
        end else begin
            log_error($sformatf("Key '%s' not found in configuration database", full_key));
            return 0;
        end
    endfunction: remove

    static function void list();
        if (store.num() == 0) begin
            log_debug("Configuration database is empty");
        end else begin
            log_debug("Current database contents:");
            foreach (store[key]) begin
                log_debug($sformatf("  Key: '%s', Component: %s", key, store[key].get_name()));
            end
        end
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

