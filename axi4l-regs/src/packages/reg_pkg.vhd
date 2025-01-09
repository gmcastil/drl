library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package reg_pkg is

    subtype reg_t is std_logic_vector(31 downto 0);
    type reg_a is array (natural range<>) of reg_t;

end package reg_pkg;

