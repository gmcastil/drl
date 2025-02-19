`define TEST_GET
class component_base;

    string name;

    component_base parent;
    //  value_type        identifier    [key_type]
    component_base children [string];

    function new(string name, component_base parent);
        this.name = name;
        this.parent = parent;
        if (parent != null) begin
            parent.add_child(this);
        end
    endfunction

    function void add_child(component_base child);
        if (this.children.exists(child.name)) begin
            $display("Child '%s' was already found in hierarchy", child.name);
        end else begin
            this.children[child.get_name()] = child;
        end
    endfunction: add_child

    function component_base get_parent();
        return this.parent;
    endfunction: get_parent

    function string get_name();
        return this.name;
    endfunction

    function void print_hierarchy();
        static string leader = "";
        $display("%s> %s", leader, this.get_name());
        foreach (this.children[i]) begin
            leader = {leader, "-"};
            this.children[i].print_hierarchy();
        end
        leader = "";
    endfunction: print_hierarchy

    function string get_full_hierarchical_name();
        if (this.parent != null) begin
            return {this.parent.get_full_hierarchical_name(), ".", this.get_name()};
        end
        return this.get_name();
    endfunction: get_full_hierarchical_name

endclass

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

// Need to map component base instances to config_store instances
typedef config_proxy_base config_store [string];

class config_db_mgr;

    static config_store m_rsc [component_base];
    static config_store global_rsc;

    static function void set(component_base cntxt, string inst_name, string field_name, config_proxy_base value);

        string full_key;

        // Do not store empty field names
        if (field_name == "") begin
            return;
        end

        if (cntxt == null) begin
            // FIXME? Is this how uvm_config_db stores globallly accessible values? or is it just
            // the field name?
            full_key = {inst_name, ".", field_name};
        end else begin
            if (inst_name == "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", field_name};
            end else if (field_name != "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", inst_name, ".", field_name};
            end
        end

        if (cntxt == null) begin
            global_rsc[full_key] = value;
            $display("CONFIG_DB_MGR: Global set [%s] = %p", full_key, value);
        end else begin
            // Crucial step here - if there isn't an existing entry here, then we initialzie one,
            // otherwise we extend it
            if (!m_rsc.exists(cntxt)) begin
                m_rsc[cntxt] = {};
                $display("CONFIG_DB_MGR: Initializing entry for component %s", cntxt.get_full_hierarchical_name());
            end else begin
                $display("CONFIG_DB_MGR: Extending existing entry for component %s", cntxt.get_full_hierarchical_name());
            end
            m_rsc[cntxt][full_key] = value;
            $display("CONFIG_DB_MGR: Set [%s] in %s", full_key, cntxt.get_full_hierarchical_name());
        end
    
    endfunction: set

    static function bit get(component_base cntxt, string inst_name, string field_name, ref config_proxy_base value);

        string full_key;

        if (cntxt == null) begin
            // FIXME? Is this how uvm_config_db stores globallly accessible values? or is it just
            // the field name?
            full_key = {inst_name, ".", field_name};
        end else begin
            if (inst_name == "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", field_name};
            end else if (field_name != "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", inst_name, ".", field_name};
            end
        end

        $display("CONFIG_DB_MGR: Lookup requested for [%s] in %s",
            full_key, (cntxt != null) ? cntxt.get_full_hierarchical_name() : "GLOBAL");

        // Local lookup
        if (cntxt != null && m_rsc.exists(cntxt) && m_rsc[cntxt].exists(full_key)) begin
            value = m_rsc[cntxt][full_key];
            $display("CONFIG_DB_MGR: Found [%s] in %s", full_key, cntxt.get_full_hierarchical_name());
            return 1;
        end

        // Global lookup
        if (cntxt == null && global_rsc.exists(full_key)) begin
            value = global_rsc[full_key];
            $display("CONFIG_DB_MGR: Found [%s] in GLOBAL scope", full_key);
            return 1;
        end

        // Recursive lookup through parents
        if (cntxt != null) begin
            $display("CONFIG_DB_MGR: [%s] not found in %s, checking parent...", 
                        full_key, cntxt.get_full_hierarchical_name());
            return get(cntxt.get_parent(), inst_name, field_name, value);
        end

        // Local and global lookups both failed
        $display("CONFIG_DB_MGR: Lookup FAILED for [%s]", full_key);
        return 0;

    endfunction: get

endclass: config_db_mgr

class config_db#(type T);

    static function void set(component_base cntxt, string inst_name, string field_name, T value);

        config_proxy#(T) proxy_value = new(value);
        config_db_mgr::set(cntxt, inst_name, field_name, proxy_value);

    endfunction: set

    static function bit get(component_base cntxt, string inst_name, string field_name, ref T value);

        config_proxy_base proxy_base;
        config_proxy#(T) proxy_typed;

        if (config_db_mgr::get(cntxt, inst_name, field_name, proxy_base)) begin
                $cast(proxy_typed, proxy_base);
                value = proxy_typed.obj;
            return 1;
        end else begin
            return 0;
        end

    endfunction: get

//        // Global entries
//        if (cntxt == null) begin
//            full_key = {inst_name, ".", field_name};
//            // Wrap the type-parameteried value as a proxy value
//            proxy_value = new(value);
//            config_db_mgr::global_rsc[full_key] = proxy_value;
//            $display("Storing key '%s' in global scope", full_key);
//            $display("");
//        // Local entries
//        end else begin
//
//            // Add a helper method here
//            if (config_db_mgr::m_rsc.exists(cntxt)) begin
//                $display("Extending entry in m_rsc for component %s", cntxt.get_name());
//                store = config_db_mgr::m_rsc[cntxt];
//            end else begin
//                $display("Initializing entry in m_rsc for component %s", cntxt.get_name());
//            end
//
//            // Wrap the type-parameteried value as a proxy value
//            proxy_value = new(value);
//            store[full_key] = proxy_value;
//
//            // Can store this in here because the type is derived from the base class handle it expects.
//            config_db_mgr::m_rsc[cntxt] = store;
//
//            $display("Storing key '%s' in component '%s'", full_key, cntxt.get_full_hierarchical_name());
//            dump_local();
//            $display("");
//
//        end
/*
    static function bit get(component_base cntxt, string inst_name, string field_name, ref T value);
        string full_key;
        config_store store;

        config_proxy_base cb;
        config_proxy#(T) unwrapped_value;

        bit found = 0;

        if (cntxt != null) begin

            // Models how `uvm_config_db` does key formation
            if (inst_name == "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", field_name};
            end else if (field_name != "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", inst_name, ".", field_name};
            end

            if (config_db_mgr::m_rsc.exists(cntxt) && config_db_mgr::m_rsc[cntxt].exists(full_key)) begin
                store = config_db_mgr::m_rsc[cntxt];
                store[full_key].get(cb);
                $cast(unwrapped_value, cb);
                value = unwrapped_value.obj;
                $display("DEBUG: Found key '%s' in context '%s'", full_key, cntxt.get_full_hierarchical_name());
                return 1;
            end else begin
                $display("DEBUG: Context '%s' not found in m_rsc, checking parent...", cntxt.get_full_hierarchical_name());
                found = get(cntxt.get_parent(), inst_name, field_name, value);
                if (found == 1) begin
                    return 1;
                end
            end
        end else begin
            full_key = {inst_name, ".", field_name};
            if (config_db_mgr::global_rsc.exists(full_key)) begin
                config_db_mgr::global_rsc[full_key].get(cb);
                $cast(unwrapped_value, cb);
                value = unwrapped_value.obj;
                $display("DEBUG: Found key '%s' in global store", full_key);
                return 1;
            end else begin
                $display("No match for field %s in global scope", field_name);
                return 0;
            end
        end

//        if (!m_rsc.exists(cntxt)) begin
//            $display("DEBUG: Context '%s' not found in m_rsc, checking parent...", cntxt.get_full_hierarchical_name());
//            return get(cntxt.get_parent(), inst_name, field_name, value);
//        end
//
//        // If key exists in the current components config store, unwrap the proxy into the
//        // appropriate container and then return 1
//        if (m_rsc[cntxt].exists(full_key)) begin
//            $display("DEBUG: Found key '%s' in context '%s'", full_key, cntxt.get_full_hierarchical_name());
//            store = m_rsc[cntxt];
//            store[full_key].get(cb);
//        
//            $cast(unwrapped_value, cb);
//            value = unwrapped_value.obj; 
//            return 1;
//        end
//
//        // Recursively call until we find the matching context or hit the top

    endfunction: get
*/
    static function void dump_local();

        int index = 0;
        $display("Dumping local database");
        $display("Total components: %0d", config_db_mgr::m_rsc.num());
        if (config_db_mgr::m_rsc.num() == 0) begin
            $display("Database empty!!!!");
            return;
        end

        foreach(config_db_mgr::m_rsc[cntxt]) begin
            if (cntxt == null) begin
                $display("Null context in database");
                $fatal(1);
            end else begin
                $display("context index=%0d, name = %s, full_name = %s",
                    index, cntxt.get_name(), cntxt.get_full_hierarchical_name());
                index++;
            end
        end

    endfunction: dump_local

endclass: config_db

module top;

    initial begin
        automatic component_base test_case = new("test_case", null);
        automatic component_base env = new("env", test_case);
        automatic component_base drv = new("drv", env);
        automatic component_base drv_child = new("drv_child", drv);
        automatic component_base seqr = new("seqr", env);
        automatic component_base avl_drv = new("avl_drv", env);
        automatic component_base avl_seqr = new("avl_seqr", env);

        automatic int fallback_timeout;

        // Variables to store retrieved values
        automatic int timeout;
        automatic string protocol;
        automatic bit logging_enabled;
        automatic string queue_mode;
        automatic int max_retries;
        automatic string driver_type;
        automatic bit enable_cache;

        $display("Testing config_db set...");
        
        // Global storage test
        config_db#(int)::set(null, "", "global_timeout", 100);
        
        // Local storage tests
        config_db#(string)::set(env, "", "protocol", "AXI");
        config_db#(bit)::set(drv, "", "enable_logging", 1);
        config_db#(bit)::set(drv_child, "", "dummy", 1);

        config_db#(bit)::set(drv, "", "enable_logging", 2);
        config_db#(string)::set(drv, "queue", "mode", "ROUND_ROBIN");

        config_db#(string)::set(drv, "queue", "flavor", "SPICY");
        config_db#(int)::set(drv, "", "global_timeout", 50); // Override global
        
        // Additional edge cases
        config_db#(int)::set(null, "", "max_retries", 5); // Global value
        config_db#(int)::set(seqr, "", "timeout", 200); // Setting at seqr level
        config_db#(string)::set(avl_drv, "", "driver_type", "AVALON"); // Unique driver setting
        config_db#(bit)::set(avl_seqr, "", "enable_cache", 0); // Unique sequencer setting
        
        $display("Set operation completed.");

`ifdef TEST_GET
        // Attempt to retrieve values from different levels
        $display("Retrieving 'global_timeout' from drv...");
        config_db#(int)::get(drv, "", "global_timeout", timeout);
            /* $display("FOUND: global_timeout = %0d", timeout); */
        /* else */
            /* $display("NOT FOUND: global_timeout"); */

        $display("Retrieving 'protocol' from drv...");
        config_db#(string)::get(drv, "", "protocol", protocol);
            /* $display("FOUND: protocol = %s", protocol); */
        /* else */
            /* $display("NOT FOUND: protocol"); */

        $display("Retrieving 'enable_logging' from drv...");
        config_db#(bit)::get(drv, "", "enable_logging", logging_enabled);
            /* $display("FOUND: enable_logging = %b", logging_enabled); */
        /* else */
            /* $display("NOT FOUND: enable_logging"); */

        $display("Retrieving 'mode' from drv.queue...");
        config_db#(string)::get(drv, "queue", "mode", queue_mode);
            /* $display("FOUND: mode = %s", queue_mode); */
        /* else */
            /* $display("NOT FOUND: mode"); */

        // Test global fallback when local is not found
        $display("Retrieving 'global_timeout' from env (should fallback to global)...");
        config_db#(int)::get(env, "", "global_timeout", fallback_timeout);
            /* $display("FOUND: global_timeout = %0d", fallback_timeout); */
        /* else */
            /* $display("NOT FOUND: global_timeout"); */
        
        // Additional edge case retrieval tests
        $display("Retrieving 'max_retries' globally...");
        config_db#(int)::get(null, "", "max_retries", max_retries);
            /* $display("FOUND: max_retries = %0d", max_retries); */
        /* else */
            /* $display("NOT FOUND: max_retries"); */

        $display("Retrieving 'timeout' from seqr...");
        config_db#(int)::get(seqr, "", "timeout", timeout);
            /* $display("FOUND: timeout = %0d", timeout); */
        /* else */
            /* $display("NOT FOUND: timeout"); */

        $display("Retrieving 'driver_type' from avl_drv...");
        config_db#(string)::get(avl_drv, "", "driver_type", driver_type);
            /* $display("FOUND: driver_type = %s", driver_type); */
        /* else */
            /* $display("NOT FOUND: driver_type"); */

        $display("Retrieving 'enable_cache' from avl_seqr...");
        config_db#(bit)::get(avl_seqr, "", "enable_cache", enable_cache);
            /* $display("FOUND: enable_cache = %b", enable_cache); */
        /* else */
            /* $display("NOT FOUND: enable_cache"); */
        $display("Retrieving 'missing' from avl_seqr...");
        config_db#(bit)::get(avl_seqr, "", "missing", enable_cache);

`endif

    end

endmodule
