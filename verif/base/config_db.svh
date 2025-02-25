virtual class config_proxy_base;

    pure virtual function void get(ref config_proxy_base value);

endclass: config_proxy_base

class config_proxy#(type T) extends config_proxy_base;

    T obj;

    function new(T value);
        this.obj = value;
    endfunction: new

    function void get(ref config_proxy_base value);
        $cast(value, this);
    endfunction: get

endclass: config_proxy

// A type-safe configuration database manager which stores and retrieves
// wrapped proxy classes in either a hierarchical or global store.
class config_db_mgr;

    // This design follows a singleton programming pattern
    static config_db_mgr singleton_instance;

    // Need to map component base instances to config_store instances
    // (unused outside this class). This is an associative array with
    // strings as the keys and config_proxy_base (proxies for the
    // type-parameterized config_proxy#(type T) types)
    typedef config_proxy_base config_store [string];

    string name;

    // Global and scoped storage with component_base objects as the keys and
    // config_store objects (associative arrays) as the values
    config_store scoped_rsc [component_base];
    config_store global_rsc;

    // Queue for storing scoped and global keys as they enter, so theyed
    // can be dump later in the order they were stored
    string scoped_key_queue [component_base] [$];
    string global_key_queue [$];

    protected function new(string name);
        this.name = name;
        `report_info(this.name, "Configuration database created", LOG_LOW);
    endfunction: new
    
    static function config_db_mgr get_instance();
        if (singleton_instance == null) begin
            singleton_instance = new("config_db");
        end
        return singleton_instance;
    endfunction: get_instance

    function void set(component_base cntxt, string inst_name, string field_name, config_proxy_base value);

        string msg;
        string full_key = config_db_build_key(cntxt, inst_name, field_name);

        // Setting global keys here
        if (cntxt == null) begin

            // Track unique callers only - most callers will have many keys
            if (!this.global_rsc.exists(full_key)) begin
                this.global_key_queue.push_back(full_key);
            end
            this.global_rsc[full_key] = value;

            msg = $sformatf("SET global [%s] => %p", full_key, value);
            `report_debug(this.name, msg);

        // Otherwise we set scopedkeys
        end else begin

            // Crucial step here - if there isn't an existing entry
            // here, then we initialzie one, otherwise we extend it
            if (!this.scoped_rsc.exists(cntxt)) begin
                this.scoped_rsc[cntxt] = {};
                msg = $sformatf("Initializing entry for component %s", cntxt.get_full_name());
            end else begin
                msg = $sformatf("Extending existing entry for component %s", cntxt.get_full_name());
            end
            `report_debug(this.name, msg);

            // Track unique callers only - most callers will have many keys
            if (!this.scoped_rsc[cntxt].exists(full_key)) begin
                this.scoped_key_queue[cntxt].push_back(full_key);
            end
            this.scoped_rsc[cntxt][full_key] = value;

            msg = $sformatf("SET scoped [%s] in %s", full_key, cntxt.get_full_name());
            `report_debug(this.name, msg);
        end
    
    endfunction: set

    function bit get(component_base cntxt, string inst_name, string field_name, ref config_proxy_base value);

        string msg;
        string full_key = config_db_build_key(cntxt, inst_name, field_name);

        if (cntxt == null) begin
            msg = $sformatf("Lookup requested for [%s] in global scope", full_key);
        end else begin
            msg = $sformatf("Lookup requested for [%s] in %s", full_key, cntxt.get_full_name());
        end
        `report_debug(this.name, msg);

        // Attempt a scoped lookup first
        if (cntxt != null && this.scoped_rsc.exists(cntxt) && this.scoped_rsc[cntxt].exists(full_key)) begin
            value = this.scoped_rsc[cntxt][full_key];
            msg = $sformatf("Found [%s] in local %s", full_key, cntxt.get_full_name());
            `report_debug(this.name, msg);
            return 1;
        end

        // Global lookup
        if (cntxt == null && this.global_rsc.exists(full_key)) begin
            value = this.global_rsc[full_key];
            msg = $sformatf("Found [%s] in global scope", full_key);
            `report_debug(this.name, msg);
            return 1;
        end

        // Recursive lookup through parents
        if (cntxt != null) begin
            msg = $sformatf("Could not find [%s] in %s, checking parent...", full_key, cntxt.get_full_name());
            `report_debug(this.name, msg);
            return get(cntxt.get_parent(), inst_name, field_name, value);
        end

        msg = $sformatf("Lookup failed for [%s]", full_key);
        `report_fatal(this.name, msg);
        return 0;

    endfunction: get

    // Lists all stored global keys and prints which component set each key
    function void dump_global_hierarchy();
        string key;
        // Use the key queue to dump these out so that we can preserve the order
        //
        // TODO Refactor this and the other one so that these go through the logger
        // instead of just displaye dto the console. Build up the string recursively and then just
        // use the `report_info() to print it
        $display("INFO: Global config_db dump");
        foreach (global_key_queue[i]) begin
            key = global_key_queue[i];
            $display("  %s", key);
        end
        $display("");

    endfunction

    function void dump_scoped_hierarchy();
        component_base comp;
        string key;
        string keys[$];

        // TODO Refactor per the previous functions too
        $display("INFO: Scoped config_db dump");
        foreach (scoped_rsc[comp]) begin
            $display("  %s (%s)", comp.get_name(), comp.get_full_name());
            keys = scoped_key_queue[comp];
            for (int i = 0; i < keys.size(); i++) begin
                $display("    %s", keys[i]);
            end
                $display("");
        end
    endfunction

endclass: config_db_mgr

// User facing side of the configuration database. Basically just
// responsible for wrapping the value that was passed in and then
// calling set or get on the database manager class.
class config_db#(type T);

    static function void set(component_base cntxt, string inst_name, string field_name, T value);

        config_proxy#(T) proxy_value = new(value);
        config_db_mgr::get_instance().set(cntxt, inst_name, field_name, proxy_value);

    endfunction: set

    static function bit get(component_base cntxt, string inst_name, string field_name, ref T value);

        config_proxy_base proxy_base;
        config_proxy#(T) proxy_typed;

        if (config_db_mgr::get_instance().get(cntxt, inst_name, field_name, proxy_base)) begin
            $cast(proxy_typed, proxy_base);
            value = proxy_typed.obj;
            return 1;
        end else begin
            return 0;
        end

    endfunction: get

endclass: config_db

// Helper function to construct keys properly depending on whether the
// context or instance is provided.
function string config_db_build_key(component_base cntxt, string inst_name, string field_name);

    string full_key;
    string msg;

    if (field_name == "") begin
        // $display("No key for you");
        msg = $sformatf("CONFIG_DB_MGR ERROR: Field name is empty! Context: %s, inst_name: %s",
                        (cntxt != null) ? cntxt.get_full_name() : "GLOBAL",
                        (inst_name != "") ? inst_name : "<empty>");
        $stacktrace;
        $fatal(1, msg);
    end

    if (cntxt == null) begin
        full_key = inst_name;
    end else if (inst_name == "") begin
        full_key = cntxt.get_full_name();
    end else begin
        full_key = {cntxt.get_full_name(), ".", inst_name};
    end

    // Before appending the field name, make sure its not the empty string (e.g., global
    // registration without an inst_name
    if (full_key == "") begin
        full_key = field_name;
    end else begin
        full_key = {full_key, ".", field_name};
    end

    return full_key;

endfunction: config_db_build_key

