virtual class object_base;

    string name;

    log_level_t current_log_level = default_log_level;

    function new(string name);
        this.name = name;
    endfunction: new

    function string get_name();
        return this.name;
    endfunction: get_name

    virtual function void set_log_level(log_level_t level);
        this.current_log_level = level;
    endfunction: set_log_level

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction: get_log_level

    // Use the static logger class for logging with just the name of the object
    virtual function void log(log_level_t level, string msg, string id = "");
        if (level >= this.current_log_level) begin
            logger::log(level, this.get_name(), msg, id);
        end
    endfunction: log

endclass: object_base

