class objection_mgr extends object_base;

    string name = "objection_mgr";

    // Access to the counter needs to be locked and accessible only through
    // the raising and dropping tasks.
    protected semaphore objection_sem = new(1);
    protected static int objection_cnt = 0;

    event test_done;

    function new(string name = name);
        super.new(name);
    endfunction: new

    task raise(object_base source);
        this.objection_sem.get();
        log_debug($sformatf("Unlocked objection manager for %s", source.get_full_hierarchical_name()));

        this.objection_cnt++;
        log_debug($sformatf("Objection raised by %s. Current objections = %0d",
                    source.get_full_hierarchical_name(), objection_cnt));

        this.objection_sem.put();
        log_debug($sformatf("Locked objection manager for %s", source.get_full_hierarchical_name()));
    endtask: raise

    task drop(object_base source);
        this.objection_sem.get();
        log_debug($sformatf("Unlocked objection manager for %s", source.get_full_hierarchical_name()));
        if (this.objection_cnt == 0) begin
            log_fatal($sformatf("Attempt by %s to drop objection failed", source.get_full_hierarchical_name()));
        end

        this.objection_cnt--;
        log_debug($sformatf("Objection dropped by %s. Current objections = %0d",
                    source.get_full_hierarchical_name(), objection_cnt));
        this.objection_sem.put();
        log_debug($sformatf("Locked objection manager for %s", source.get_full_hierarchical_name()));

        if (this.objection_cnt == 0) begin
            log_info("All objections dropped. Ending the test");
            ->test_done;
        end
    endtask: drop

endclass

