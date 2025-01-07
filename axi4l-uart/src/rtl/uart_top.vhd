library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;
use work.uart_pkg.all;

entity uart_top is
    generic (
        -- Required for device or platform specific features (e.g., FIFO primitives)
        DEVICE              : string                := "7SERIES";
        -- Define the location and size of UART in memory map
        BASE_OFFSET         : unsigned(31 downto 0) := (others=>'0');
        BASE_OFFSET_MASK    : unsigned(31 downto 0) := (others=>'0');
        -- When set to false, the RX or TX hardware is not instantiated and will be bypassed
        RX_ENABLE           : boolean               := true;
        TX_ENABLE           : boolean               := true;
        -- Instrument the AXI and register interfaces in an ILA core
        DEBUG_UART_AXI      : boolean               := false;
        -- Instrument UART control and status signals
        DEBUG_UART_CTRL     : boolean               := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- AXI4-Lite register interface
        axi4l_awvalid       : in    std_logic;
        axi4l_awready       : out   std_logic;
        axi4l_awaddr        : in    std_logic_vector(31 downto 0);

        axi4l_wvalid        : in    std_logic;
        axi4l_wready        : out   std_logic;
        axi4l_wdata         : in    std_logic_vector(31 downto 0);
        axi4l_wstrb         : in    std_logic_vector(3 downto 0);

        axi4l_bvalid        : out   std_logic;
        axi4l_bready        : in    std_logic;
        axi4l_bresp         : out   std_logic_vector(1 downto 0);

        axi4l_arvalid       : in    std_logic;
        axi4l_arready       : out   std_logic;
        axi4l_araddr        : in    std_logic_vector(31 downto 0);

        axi4l_rvalid        : out   std_logic;
        axi4l_rready        : in    std_logic;
        axi4l_rdata         : out   std_logic_vector(31 downto 0);
        axi4l_rresp         : out   std_logic_vector(1 downto 0);

        -- IRQ to global interrupt controller (GIC)
        irq                 : out   std_logic;

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic
    );

end entity uart_top;

architecture structural of uart_top is

    signal reg_addr             : unsigned(REG_ADDR_WIDTH-1 downto 0);
    signal reg_wdata            : std_logic_vector(31 downto 0);
    signal reg_wren             : std_logic;
    signal reg_be               : std_logic_vector(3 downto 0);
    signal reg_rdata            : std_logic_vector(31 downto 0);
    signal reg_req              : std_logic;
    signal reg_ack              : std_logic;
    signal reg_err              : std_logic;

    signal rx_rst               : std_logic;
    signal tx_rst               : std_logic;
    signal rx_en                : std_logic;
    signal tx_en                : std_logic;

    signal parity               : std_logic_vector(2 downto 0);
    signal char                 : std_logic_vector(1 downto 0);
    signal nbstop               : std_logic_vector(1 downto 0);

    signal cfg                  : std_logic_vector(31 downto 0);
    signal scratch              : std_logic_vector(31 downto 0);

    signal baud_div             : unsigned(14 downto 0);
    signal baud_cnt             : unsigned(14 downto 0);
    signal baud_gen_en          : std_logic;

    signal tx_data              : std_logic_vector(7 downto 0);
    signal tx_data_valid        : std_logic;
    signal tx_data_ready        : std_logic;

begin

    uart_core_i0: entity work.uart_core
    generic map (
        DEVICE              => DEVICE,
        RX_ENABLE           => RX_ENABLE,
        TX_ENABLE           => TX_ENABLE
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        rx_rst              => rx_rst,
        rx_en               => rx_en,
        tx_rst              => tx_rst,
        tx_en               => tx_en,
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        tx_data             => tx_data,
        tx_data_valid       => tx_data_valid,
        tx_data_ready       => tx_data_ready,
        rxd                 => rxd,
        txd                 => txd
    );

    uart_ctrl_i0: entity work.uart_ctrl
    generic map (
        RX_ENABLE           => RX_ENABLE,
        TX_ENABLE           => TX_ENABLE,
        DEBUG_UART_AXI      => DEBUG_UART_AXI,
        DEBUG_UART_CTRL     => DEBUG_UART_CTRL
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
        rx_rst              => rx_rst,
        rx_en               => rx_en,
        tx_rst              => tx_rst,
        tx_en               => tx_en,
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        tx_data             => tx_data,
        tx_data_valid       => tx_data_valid,
        tx_data_ready       => tx_data_ready
    );

    axi4l_regs_i0: entity work.axi4l_regs
    generic map (
        BASE_OFFSET         => BASE_OFFSET,
        BASE_OFFSET_MASK    => BASE_OFFSET_MASK,
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH
    )
    port map (
        clk                 => clk,
        rstn                => not rst,
        s_axi_awaddr        => axi4l_awaddr,
        s_axi_awvalid       => axi4l_awvalid,
        s_axi_awready       => axi4l_awready,
        s_axi_wdata         => axi4l_wdata,
        s_axi_wstrb         => axi4l_wstrb,
        s_axi_wvalid        => axi4l_wvalid,
        s_axi_wready        => axi4l_wready,
        s_axi_bresp         => axi4l_bresp,
        s_axi_bvalid        => axi4l_bvalid,
        s_axi_bready        => axi4l_bready,
        s_axi_araddr        => axi4l_araddr,
        s_axi_arvalid       => axi4l_arvalid,
        s_axi_arready       => axi4l_arready,
        s_axi_rdata         => axi4l_rdata,
        s_axi_rresp         => axi4l_rresp,
        s_axi_rvalid        => axi4l_rvalid,
        s_axi_rready        => axi4l_rready,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err
    );

    -- Instrument the AXI interface and the internal register interface
    g_axi_dbg: if (DEBUG_UART_AXI) generate
        uart_axi4l_ila_i0: entity work.uart_axi4l_ila
        port map (
            clk                 => clk,
            probe0(0)           => rst,
            probe1(0)           => axi4l_awvalid,
            probe2(0)           => axi4l_awready,
            probe3              => axi4l_awaddr,
            probe4(0)           => axi4l_wvalid,
            probe5(0)           => axi4l_wready,
            probe6              => axi4l_wdata,
            probe7              => axi4l_wstrb,
            probe8(0)           => axi4l_bvalid,
            probe9(0)           => axi4l_bready,
            probe10             => axi4l_bresp,
            probe11(0)          => axi4l_arvalid,
            probe12(0)          => axi4l_arready,
            probe13             => axi4l_araddr,
            probe14(0)          => axi4l_rvalid,
            probe15(0)          => axi4l_rready,
            probe16             => axi4l_rdata,
            probe17             => axi4l_rresp,
            probe18             => std_logic_vector(reg_addr),
            probe19             => reg_wdata,
            probe20(0)          => reg_wren,
            probe21             => reg_be,
            probe22             => reg_rdata,
            probe23(0)          => reg_req,
            probe24(0)          => reg_ack,
            probe25(0)          => reg_err
        );
    end generate g_axi_dbg;

end architecture structural;

