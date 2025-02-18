virtual class proxy_base;

    pure virtual function void get(ref proxy_base value);

endclass: proxy_base

class proxy_element#(type T) extends proxy_base;

    T obj;

    function new(T value);
        this.obj = value;
    endfunction: new

    function void get(ref proxy_base value);
        $cast(value, this);
    endfunction: get

endclass: proxy_element

class config_element;

    string scope;
    string role;

    proxy_base obj;

    function new(string scope, string role, proxy_base value);

        this.scope = scope;
        this.role = role;
        this.obj = value;

    endfunction: new

endclass: config_element
// 
// class config_db#(type t);
// 
//     static proxy_base store [string];
// 
//     static function void set(string scope, string role, t value);
// 
//         string key = {scope, ".", role};
//         proxy_element#(t) proxied = new(value);
//         store[key] = proxied;
// 
//     endfunction: set
// 
// endclass: config_db

module top ();

    initial begin
        automatic proxy_element#(int) p = new(42);
        automatic config_element e = new("parent", "entry", p);

        automatic proxy_element#(string) p_str = new("hello");
        automatic config_element e_str = new("parent_2", "entry_2", p_str);
    end

endmodule: top

        /* config_element element; */
        /* proxy_element#(int) proxied; */

        /* proxied = new(42); */
        /* element = new("parent", "entry", proxied); */

