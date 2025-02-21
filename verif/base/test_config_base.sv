virtual class test_config_base extends object_base;

    function new(string name);
        super.new(name);
    endfunction: new

    // Filenames for corresponding memory models used for capturing and generating data from disk.
    // These strings need to match the names returned by memory_model::get_name() or whatever the
    // environment named them as.
    protected string memory_files [string];

    virtual function void set_memory_file(string model_name, string filename);
        if (model_name == "" || filename == "") begin
            log_fatal("Memory model or filenames cannot be empty");
        end

        if (this.memory_files.exists(model_name)) begin
            log_info($sformatf("Overriding memory model filename: %s -> %s",
                this.memory_files[model_name], filename));
        end else begin
            this.memory_files[model_name] = filename;
            log_info($sformatf("Set filename for memory model %s to %s",
                model_name, this.memory_files[model_name]));
        end

    endfunction: set_memory_file

    virtual function string get_memory_file(string model_name);

        if (this.memory_files.exists(model_name)) begin
            return this.memory_files[model_name];
        end else begin
            log_error($sformatf("No memory file set in configuration for memory model %s", model_name));
            return "";
        end

    endfunction: get_memory_file

endclass: test_config_base

