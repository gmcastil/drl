library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;
use work.uart_pkg.all;

entity uart_ctrl is
    generic (
        -- Top level generics need to be passed in here so that they can be reported back
        -- to software in the configuration register
        RX_ENABLE           : boolean       := true;
        TX_ENABLE           : boolean       := true;
        DEBUG_UART_AXI      : boolean       := false;
        DEBUG_UART_CTRL     : boolean       := false
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        -- Register interface bus 
        reg_addr            : in  unsigned(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : in  std_logic_vector(31 downto 0);
        reg_wren            : in  std_logic;
        reg_be              : in  std_logic_vector(3 downto 0);
        reg_rdata           : out std_logic_vector(31 downto 0);
        reg_req             : in  std_logic;
        reg_ack             : out std_logic;
        reg_err             : out std_logic;

        -- Control and status bits between the UART core and the external control interface
        rx_rst              : out std_logic;
        rx_en               : out std_logic;
        tx_rst              : out std_logic;
        tx_en               : out std_logic;

        parity              : out std_logic_vector(2 downto 0);
        nbstop              : out std_logic_vector(1 downto 0);
        char                : out std_logic_vector(1 downto 0);

        baud_div            : out unsigned(14 downto 0);
        baud_cnt            : in  unsigned(14 downto 0);
        baud_gen_en         : out std_logic;

        tx_data             : out std_logic_vector(7 downto 0);
        tx_data_valid       : out std_logic;
        tx_data_ready       : in  std_logic
    );

end entity uart_ctrl;

architecture rtl of uart_ctrl is

    signal rd_regs              : reg_a(NUM_REGS-1 downto 0);
    signal wr_regs              : reg_a(NUM_REGS-1 downto 0);

    signal cfg                  : std_logic_vector(31 downto 0);
    signal scratch              : std_logic_vector(31 downto 0);

begin

    -- The config register isn't actually used anywhere in the hardware, but it
    -- still gets created and assigned in the control core ILA.
    cfg         <= std_logic_vector(rd_regs(CONFIG_REG)); 

    -- Register 0: UART control register

    -- Register 1: UART mode register
    
    -- Defines expected parity to check on receive and sent on transmit
    --  000 - Even
    --  001 - Odd
    --  01x - None
    --  100 - Forced even
    --  110 - Forced odd
    parity          <= wr_regs(MODE_REG)(10 downto 8);
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
    rd_regs(CONFIG_REG)(8)                      <= '1' when DEBUG_UART_CTRL else '0';
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
    scratch         <= std_logic_vector(wr_regs(SCRATCH_REG));

    -- The register block is instantiated with generics defined in `uart_pkg`
    uart_regs_i0: entity work.reg_block
    generic map (
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH,
        NUM_REGS            => NUM_REGS,
        REG_WRITE_MASK      => REG_WRITE_MASK
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
    );

    -- Instrument the control and status bits at the UART core. This
    -- is intended for driver debug not for general hardware debug.
    -- Generate a different core for that or use MARK_DEBUG attributes
    -- and a post-synthesis ILA.
    g_uart_ctrl_dbg: if (DEBUG_UART_CTRL) generate
        uart_ctrl_ila_i0: entity work.uart_ctrl_ila
        port map (
            clk                 => clk,
            probe0(0)           => rst,
            probe1(0)           => rx_rst,
            probe2(0)           => rx_en,
            probe3(0)           => tx_rst,
            probe4(0)           => tx_en,
            probe5              => parity,
            probe6              => char,
            probe7              => nbstop,
            probe8              => std_logic_vector(baud_div),
            probe9              => std_logic_vector(baud_cnt),
            probe10(0)          => baud_gen_en,
            probe11             => cfg,
            probe12             => scratch
        );
    end generate g_uart_ctrl_dbg;

end architecture rtl;

