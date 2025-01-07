library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;
use work.uart_pkg.all;

entity uart_reg_map is
    generic (
        NUM_REGS            : natural       := 16;
        -- These generics are passed in
        RX_ENABLE           : boolean       := true;
        TX_ENABLE           : boolean       := true;
        DEBUG_UART_AXI      : boolean       := false;
        DEBUG_UART_CORE     : boolean       := false
    );
    port (

        rx_rst              : out std_logic;
        rx_en               : out std_logic;
        tx_rst              : out std_logic;
        tx_en               : out std_logic;

        parity              : out std_logic_vector(1 downto 0);
        nbstop              : out std_logic_vector(1 downto 0);
        char                : out std_logic_vector(1 downto 0);

        cfg                 : out std_logic_vector(31 downto 0);
        scratch             : out std_logic_vector(31 downto 0);

        baud_div            : out unsigned(14 downto 0);
        baud_cnt            : in  unsigned(14 downto 0);
        baud_gen_en         : out std_logic;

        rd_regs             : out reg_a(NUM_REGS-1 downto 0);
        wr_regs             : in  reg_a(NUM_REGS-1 downto 0)
    );

end entity uart_reg_map;

architecture arch of uart_reg_map is

begin

    -- The config register isn't actually used anywhere in the hardware, but it
    -- still needs to be exported so it appears in the top level debug ILA
    cfg         <= std_logic_vector(rd_regs(CONFIG_REG)); 
    -- Same story with the scratch register
    scratch     <= std_logic_vector(wr_regs(SCRATCH_REG));

    -- Register 0: UART control register

    -- Register 1: UART mode register
    
    -- Defines expected parity to check on receive and sent on transmit
    --  00 - Even
    --  01 - Odd
    --  1x - None
    parity          <= wr_regs(MODE_REG)(9 downto 8);
    -- Defines the number of expected stop bits
    --  00 - 1 stop bit
    --  01 - 1.5 stop bits
    --  1x - 2 stop bits
    nbstop          <= wr_regs(MODE_REG)(5 downto 4);
    -- Defines the number of bits to transmit or receive per character
    --  00 - 6 bits
    --  01 - 7 bits
    --  1x - 8 bits
    char            <= wr_regs(MODE_REG)(1 downto 0); 

    -- Register 2: UART status register

    -- Register 3: Build configuration register
    rd_regs(CONFIG_REG)(31 downto 24)           <= (others=>'0');
    rd_regs(CONFIG_REG)(23 downto 16)           <= (others=>'0');
    rd_regs(CONFIG_REG)(15 downto 10)           <= (others=>'0');
    rd_regs(CONFIG_REG)(9)                      <= '1' when DEBUG_UART_AXI else '0';
    rd_regs(CONFIG_REG)(8)                      <= '1' when DEBUG_UART_CORE else '0';
    rd_regs(CONFIG_REG)(7 downto 5)             <= (others=>'0');
    rd_regs(CONFIG_REG)(4)                      <= '1' when TX_ENABLE else '0';
    rd_regs(CONFIG_REG)(3 downto 1)             <= (others=>'0');
    rd_regs(CONFIG_REG)(0)                      <= '1' when RX_ENABLE else '0';

    -- Register 6: Baud rate generator status
    rd_regs(BAUD_GEN_STATUS_REG)(31 downto 15)  <= (others=>'0');
    rd_regs(BAUD_GEN_STATUS_REG)(14 downto 0)   <= std_logic_vector(baud_cnt);

    -- Register 7: Baud rate generator register
    --          0  Enable = 1, Disable = 0
    --    15 -  1  15 bits for the baud_div
    --    31 - 16  Unused
    baud_div        <= unsigned(wr_regs(BAUD_GEN_CTRL_REG)(15 downto 1));
    baud_gen_en     <= wr_regs(BAUD_GEN_CTRL_REG)(0);

    -- Register 15: UART scratch register

end architecture arch;
