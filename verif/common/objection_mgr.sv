class objection_mgr;

    static string name = "objection_mgr";
    static log_level_t current_log_level = default_Log_level;

    // Access to the counter needs to be locked and accessible only through
    // the raising and dropping tasks.
    static semaphore objection_sem = new(1);
    protected static int objection_cnt = 0;

    static event test_done;

    static task raise(string source);
        objection_sem.get();
        log(LOG_DEBUG, $sformatf("Unlocked objection manager for %s", source));

        objection_cnt++;
        log(LOG_DEBUG, $sformatf("Objection raised by %s. Current objections = %0d",
                    source, objection_cnt));

        objection_sem.put();
        log(LOG_DEBUG, $sformatf("Locked objection manager for %s", source));
    endtask: raise

    static task drop(string source);
        objection_sem.get();
        log(LOG_DEBUG, $sformatf("Unlocked objection manager for %s", source));
        if (objection_cnt == 0) begin
            // FIXME to use log_fatal() instead
            log(LOG_FATAL, $sformatf("Attempt by %s to drop objection failed", source));
            $fatal(1);
        end

        objection_cnt--;
        log(LOG_DEBUG, $sformatf("Objection dropped by %s. Current objections = %0d",
                    source, objection_cnt));
        objection_sem.put();
        log(LOG_DEBUG, $sformatf("Locked objection manager for %s", source));

        if (objection_cnt == 0) begin
            log(LOG_INFO, "All objections dropped. Ending the test");
            ->test_done;
        end
    endtask: drop

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

endclass

