library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_pkg is

    -- Width of the register interface bridged from the AXI bus
    constant REG_ADDR_WIDTH     : natural := 4;
    -- Number of registers exposed
    constant NUM_REGS           : natural := 16;
    -- Mask to determine which registers are externally writable or only readable
    constant REG_WRITE_MASK     : std_logic_vector(NUM_REGS-1 downto 0) := b"1000_0000_1000_0011";

    constant CTRL_REG               : natural := 0;
    constant MODE_REG               : natural := 1;
    constant STATUS_REG             : natural := 2;
    constant CONFIG_REG             : natural := 3;
    constant BAUD_GEN_STATUS_REG    : natural := 6;
    constant BAUD_GEN_CTRL_REG      : natural := 7;
    constant SCRATCH_REG            : natural := 15;

end package uart_pkg;

