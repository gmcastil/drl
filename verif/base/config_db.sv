class config_db;

    static string name = "config_db";
    static log_level_t current_log_level = default_log_level;

    // The configuration database can store component references as well as sequences,
    // transactions, and anything else that derives from this lowest base class
    static object_base store [string];

    static function bit set(string scope, string key, object_base value);
        string msg;
        string full_key;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
                log(LOG_ERROR, $sformatf("Key '%s' was already found in configuration database", full_key));
            return 0;
        end else begin
            store[full_key] = value;
            msg = $sformatf("Registered %s in configuration database with key %s", value.get_name(), full_key);
            log(LOG_DEBUG, msg, "SET");
            return 1;
        end
    endfunction: set

    static function bit get(string scope, string key, ref object_base value);
        string msg;
        string full_key;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            value = store[full_key];
            msg = $sformatf("Retrieved %s from configuration database with key %s", value.get_name(), full_key);
            log(LOG_DEBUG, msg, "GET");
            return 1;
        end else begin
            log(LOG_WARN, $sformatf("Key '%s' not found in configuration database", full_key));
            return 0;
        end
    endfunction: get

    static function bit remove(string scope, string key);
        string msg;
        string full_key;
        object_base value;

        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            value = store[full_key];
            msg = $sformatf("Deleted %s from configuration database with key %s", value.get_name(), full_key);
            store.delete(full_key);
            log(LOG_DEBUG, msg, "DEL");
            return 1;
        end else begin
            log(LOG_WARN, $sformatf("Key '%s' not found in configuration database", full_key));
            return 0;
        end
    endfunction: remove

    static function void list();
        if (store.num() == 0) begin
            log(LOG_DEBUG, "Configuration database is empty");
        end else begin
            log(LOG_DEBUG, "Current database contents:");
            foreach (store[key]) begin
                log(LOG_DEBUG, $sformatf("  Key: '%s', Component: %s", key, store[key].get_name()));
            end
        end
    endfunction: list

    static function void set_log_level(log_level_t level);
        current_log_level = level;
    endfunction: set_log_level

    static function log_level_t get_log_level();
        return current_log_level;
    endfunction: get_log_level

    static function void log(log_level_t level, string msg, string id = "");
        if (level >= current_log_level) begin
            logger::log(level, name, msg, id);
        end
    endfunction: log

endclass: config_db

