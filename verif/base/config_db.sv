class config_db;

    static string name = "config_db";
    static log_level_t current_log_level = default_log_level;

    // The configuration database only stores references to this type
    static component_base store [string];
    // Need to lock the database so we can safely access its elements
    static semaphore store_sem = new(1);

    static task put(string scope, string key, component_base value);
        automatic string full_key;
        store_sem.get();
        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            log(LOG_ERROR, $sformatf("Key '%s' was already found in configuration database", full_key));
        end else begin
            store[full_key] = value;
            log(LOG_INFO, $sformatf("Added key '%s' with value: %p", full_key, value));
        end
        store_sem.put();
    endtask: put

    static task get(string scope, string key, ref component_base value);
        automatic string full_key;
        store_sem.get();
        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            value = store[full_key];
        end else begin
            log(LOG_WARN, $sformatf("Key '%s' not found in configuration database", full_key));
        end
        store_sem.put();
    endtask: get

    static task remove(string scope, string key);
        automatic string full_key;
        store_sem.get();
        full_key = {scope, ".", key};
        if (store.exists(full_key)) begin
            store.delete(full_key);
            log(LOG_INFO, $sformatf("Removed key '%s' found configuration database", full_key));
        end else begin
            log(LOG_WARN, $sformatf("Key '%s' not found in configuration database", full_key));
        end
        store_sem.put();
    endtask: remove

    static task list();
        store_sem.get();
        if (store.num() == 0) begin
            log(LOG_INFO, "Configuration database is empty");
        end else begin
            log(LOG_DEBUG, "Current database contents:");
            foreach (store[key]) begin
                log(LOG_DEBUG, $sformatf("  Key: '%s', Component: %s", key, store[key].get_name()));
            end
        end
        store_sem.put();
    endtask: list

    static function void set_log_level(log_level_t level);
        current_log_level = level;
    endfunction: set_log_level

    static function log_level_t get_log_level();
        return current_log_level;
    endfunction: get_log_level

    static function void log(log_level_t level, string msg);
        if (level >= current_log_level) begin
            $display("[%0t] [%s] [%s] %s", $time, name, level.name(), msg);
        end
    endfunction: log

endclass: config_db

