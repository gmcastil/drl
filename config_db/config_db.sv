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
        return this.name;
    endfunction: get_full_hierarchical_name

endclass

virtual class config_proxy_base;

    pure virtual function void get(ref config_proxy_base value);

    pure virtual function void display();

endclass: config_proxy_base

class config_proxy#(type T) extends config_proxy_base;

    T obj;

    function new(T value);
        this.obj = value;
    endfunction: new

    function void get(ref config_proxy_base value);
        $cast(value, this);
    endfunction: get

    function void display();
        $display("my obj = %s", this.obj);
    endfunction

endclass: config_proxy

class config_db#(type T);

    // Need to map component base instances to config_store instances
    //       value_type       idetnifier    [key_tyupe]
    typedef config_proxy_base config_store [string];

    static config_store m_rsc [component_base];
    static config_store global_rsc;

    static function void set(component_base cntxt, string inst_name, string field_name, T value);
        string full_key;
        config_store m_rsc_element;
        config_proxy#(T) proxy_value;

        // Do not store empty field names
        if (field_name == "") begin
            return;
        end

        // Global entries
        if (cntxt == null) begin
            full_key = {inst_name, "::", field_name};

            // Wrap the type-parameteried value as a proxy value
            proxy_value = new(value);
            global_rsc[full_key] = proxy_value;

        // Local entries
        end else begin
            if (inst_name == "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", field_name};
            end else if (field_name != "") begin
                full_key = {cntxt.get_full_hierarchical_name(), ".", inst_name, ".", field_name};
            end

            // Wrap the type-parameteried value as a proxy value
            proxy_value = new(value);
            m_rsc_element[full_key] = proxy_value;

            if (!m_rsc.exists(cntxt)) begin
                $display("Initializing entry in m_rsc for component %s", cntxt.get_name());
            end

            // Can store this in here because the type is derived from the base class handle it expects.
            m_rsc[cntxt] = m_rsc_element;

            $display("DEBUG: Storing key '%s' in component '%s'", full_key, cntxt.get_full_hierarchical_name());
        end

    endfunction: set

    static function bit get(component_base cntxt, string inst_name, string field_name, ref T value);
        string full_key;
        config_store cs;
        config_proxy_base cb;

        config_proxy#(T) unwrapped_value;

        if (cntxt == null) begin
            $display("Context null or field not found in database", field_name);
            return 0;
        end

        if (!m_rsc.exists(cntxt)) begin
            $display("DEBUG: Context '%s' not found in m_rsc, checking parent...", cntxt.get_full_hierarchical_name());
            return get(cntxt.get_parent(), inst_name, field_name, value);
        end

        // Models how `uvm_config_db` does key formation
        if (inst_name == "") begin
            full_key = {cntxt.get_full_hierarchical_name(), ".", field_name};
        end else if (field_name != "") begin
            full_key = {cntxt.get_full_hierarchical_name(), ".", inst_name, ".", field_name};
        end

        // If key exists in the current components config store, unwrap the proxy into the
        // appropriate container and then return 1
        if (m_rsc[cntxt].exists(full_key)) begin
            $display("DEBUG: Found key '%s' in context '%s'", full_key, cntxt.get_full_hierarchical_name());
            cs = m_rsc[cntxt];
            cs[full_key].get(cb);
        
            $cast(unwrapped_value, cb);
            value = unwrapped_value.obj; 
            return 1;
        end

        // Recursively call until we find the matching context or hit the top
        return get(cntxt.get_parent(), inst_name, field_name, value);

    endfunction: get

endclass: config_db

module top;

    initial begin
        automatic component_base test_case = new("test_case", null);
        automatic component_base env = new("env", test_case);
        automatic component_base drv = new("drv", env);
        automatic int fallback_timeout;

        // Variables to store retrieved values
        automatic int timeout;
        automatic string protocol;
        automatic bit logging_enabled;
        automatic string queue_mode;

        $display("Testing config_db set...");
        
        // Global storage test
        config_db#(int)::set(null, "", "global_timeout", 100);
        
        // Local storage tests
        config_db#(string)::set(env, "", "protocol", "AXI");
        config_db#(bit)::set(drv, "", "enable_logging", 1);
        config_db#(string)::set(drv, "queue", "mode", "ROUND_ROBIN");
        config_db#(int)::set(drv, "", "global_timeout", 50); // Override global

        $display("Set operation completed.");
        $fflush();

        // Attempt to retrieve values from different levels
        $display("Retrieving 'global_timeout' from drv...");
        if (config_db#(int)::get(drv, "", "global_timeout", timeout))
            $display("FOUND: global_timeout = %0d", timeout);
        else
            $display("NOT FOUND: global_timeout");

        $display("Retrieving 'protocol' from drv...");
        if (config_db#(string)::get(drv, "", "protocol", protocol))
            $display("FOUND: protocol = %s", protocol);
        else
            $display("NOT FOUND: protocol");

        $display("Retrieving 'enable_logging' from drv...");
        if (config_db#(bit)::get(drv, "", "enable_logging", logging_enabled))
            $display("FOUND: enable_logging = %b", logging_enabled);
        else
            $display("NOT FOUND: enable_logging");

        $display("Retrieving 'mode' from drv.queue...");
        if (config_db#(string)::get(drv, "queue", "mode", queue_mode))
            $display("FOUND: mode = %s", queue_mode);
        else
            $display("NOT FOUND: mode");

        // Test global fallback when local is not found
        $display("Retrieving 'global_timeout' from env (should fallback to global)...");
        if (config_db#(int)::get(env, "", "global_timeout", fallback_timeout))
            $display("FOUND: global_timeout = %0d", fallback_timeout);
        else
            $display("NOT FOUND: global_timeout");
    end

endmodule
