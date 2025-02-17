module top;


/*     typedef object_base scope_t; */
/*     typedef string role_t; */

/*     class config_db#(type T extends object_base); */

/*         /1* virtual class config_store #(type T extends object_base); *1/ */
/*         /1*     static T store [scope_t][role_t]; *1/ */
/*         /1* endclass: config_store *1/ */

/*         /1* static function void set(scope_t scope, role_t role, object_base obj); *1/ */
/*             $display("Calling set"); */
/*         endfunction: set */

/*     endclass: config_db */

/* endmodule: test_config_store */

    class object_base;
        string name;

        function new(string name);
            this.name = name;
        endfunction: new

        function void display();
            $display("name = %s", this.name);
        endfunction: display

    endclass: object_base

    class config_db #(type T);
        static T store[string][string];

        static function void set(string scope, string role, T obj);

            store[scope][role] = obj;

        endfunction

        static function bit get(string scope, string role, ref T obj);

            T from_db;
            T temp_obj;

            from_db = store[scope][role];
            if ($cast(temp_obj, from_db)) begin
                if (temp_obj == null) begin
                    $display("found object was null");
                    return 0;
                end
            end

        endfunction
    endclass

    object_base obj;

    string foo;
    int x_int;
    string x_str;
    object_base x_obj;

    bit retval;

    initial begin
        $display("Starting");

        config_db#(int)::set("temp", "1", 0);
        config_db#(string)::set("temp", "1", "");
        config_db#(object_base)::set("temp", "1", null);


        /* retval = config_db#(int)::get("temp", "1", x_int); */
        /* if (retval == 1) */
        /*     $display("retval = %0d, got %0d", retval, x_int); */

        /* retval = config_db#(string)::get("temp", "1", x_str); */
        /* if (retval == 1) */
        /*     $display("retval = %0d, got %s", retval, x_str); */

        retval = config_db#(object_base)::get("temp", "1", x_obj);
        if (retval == 1)
            $display("retval = %0d, got %s", retval, x_obj.name);

    end

endmodule

