class config_db extends object_base;

    // The configuration database can store component references as well as sequences,
    // transactions, and anything else that derives from this lowest base class
    object_base store [string];

    /* NOTE For now, use * as the scope when setting and retrieving keys for wildcards. In the
     * future refactor this to actually use wildcards so that items can be stored with the scope
     * '*' and then retrieved with whatever scope is desired.  For example, set("*", foo, bar) and
     * then retrieved with get("baz", foo, blar).  As is, you have to retrieve it with * as the
     * scope.
     */
    function new(string name);
        super.new(name);
    endfunction: new

    function bit set(string scope, string key, object_base value);
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

    function bit get(string scope, string key, ref object_base value);
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

    function bit remove(string scope, string key);
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

    function void list();
        if (store.num() == 0) begin
            log_debug("Configuration database is empty");
        end else begin
            log_debug("Current database contents:");
            foreach (store[key]) begin
                log_debug($sformatf("  Key: '%s', Component: %s", key, store[key].get_name()));
            end
        end
    endfunction: list

endclass: config_db

