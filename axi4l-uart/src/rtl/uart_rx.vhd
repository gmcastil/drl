library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        -- Input clock frequency
        CLK_FREQ    : integer       := 100000000;
        -- Desired baud rate
        BAUD_RATE   : integer       := 115200;
        -- Target device
        DEVICE      : string        := "7SERIES";
        -- FIFO size
        FIFO_SIZE   : string        := "18Kb";
        -- Enable additional FIFO pipeline stage
        DO_REG      : integer       := 1
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        -- UART RX read interface
        rd_data         : out   std_logic_vector(7 downto 0);
        rd_valid        : out   std_logic;
        rd_ready        : in    std_logic;

        -- May make sense to put a status register here and then add the overflow and ready bits to
        -- it (think driver support in the future)

        -- Indicates that UART RX is out of reset and that the FIFO is ready to receive data
        rx_ready        : out   std_logic;
        -- Number of received frames since reset
        rx_frame_cnt    : out   unsigned(31 downto 0);
        -- Number of valid frames received when the external client was not
        -- ready (i.e., dropped frames)
        rx_frame_err    : out   unsigned(31 downto 0);

        -- Indicates that frames are being received but dropped
        rx_overflow     : out   std_logic;

        -- Should map directly to the output pin of an input buffer (no IBUF is added by this
        -- module)
        uart_rxd        : in    std_logic
    );

end entity uart_rx;

architecture behavioral of uart_rx is

    -- Just support 1 start bit, 8 data bigts, no parity, and 1 stop bit
    constant RX_FRAME_LEN           : integer   := 10;

    -- Values for the start and stop bits (not the number of start or stop bits)
    constant RX_START_BIT           : std_logic := '0';
    constant RX_STOP_BIT            : std_logic := '1';

    constant BAUD_DIVISOR           : integer   := CLK_FREQ / BAUD_RATE;

    -- Asynchronous serial input needs a couple of flip flops to synchronize
    -- to this domain
    signal  uart_rxd_q              : std_logic;
    signal  uart_rxd_qq             : std_logic;
    signal  uart_rxd_qqq            : std_logic;

    signal  rx_data_sr              : std_logic_vector(7 downto 0);
    signal  rx_bit_cnt              : unsigned(3 downto 0);
    signal  baud_tick_cnt           : unsigned(15 downto 0);

    signal  rx_busy                 : std_logic;
    signal  found_start             : std_logic;

    -- Internal FIFO control signals
    signal  rx_fifo_wr_en           : std_logic;
    signal  rx_fifo_wr_data         : std_logic_vector(7 downto 0);
    signal  rx_fifo_rd_en           : std_logic;
    signal  rx_fifo_rd_data         : std_logic_vector(7 downto 0);
    signal  rx_fifo_ready           : std_logic;
    signal  rx_fifo_full            : std_logic;
    signal  rx_fifo_empty           : std_logic;

begin

    -- The reset and rx_fifo_ready signals are registered and the FIFO full indicator is driven by
    -- the Xilinx FIFO primitive.  Registering this signal would yield a clock cycle where the FIFO
    -- was full but we signal we are ready for data still, so we combine the registered values in
    -- this manner.
    rx_ready    <= '1' when (rst = '0' and rx_fifo_ready = '1' and rx_fifo_full = '0') else '0';

    -- First, need to cross the input serial data stream into the native clock
    -- domain for this module
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                uart_rxd_q      <= '1';
                uart_rxd_qq     <= '1';
                uart_rxd_qqq    <= '1';
            else
                uart_rxd_q      <= uart_rxd;
                uart_rxd_qq     <= uart_rxd_q;
                uart_rxd_qqq    <= uart_rxd_qq;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then

                -- Control bits
                rx_busy             <= '0';
                baud_tick_cnt       <= (others=>'0');
                rx_bit_cnt          <= (others=>'0');
                found_start         <= '0';

                -- FIFO controls
                rx_fifo_wr_en       <= '0';

                -- Status
                rx_overflow         <= '0';
                rx_frame_cnt        <= (others=>'0');
                rx_frame_err        <= (others=>'0');

            else
                if (rx_fifo_ready = '0') then
                    rx_busy             <= '0';
                    rx_fifo_wr_en       <= '0';
                    rx_bit_cnt          <= (others=>'0');
                    
                else
                    -- Looking for the start bit
                    if (rx_busy = '0') then
                        if (uart_rxd_qq = '0' and uart_rxd_qqq = '1') then
                            rx_busy             <= '1';
                            rx_bit_cnt          <= (others=>'0');

                            found_start         <= '0';
                            -- For the start bit, we set the counter to half the baud period
                            baud_tick_cnt       <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length) srl 1;
                            rx_overflow         <= '0';

                        end if;
                        rx_fifo_wr_en       <= '0';
                    else
                        -- Capture the start bit half a baud period into the transmission and align subsequent samples to this
                        -- point. If we didn't capture a start bit, then back to the idle or not busy condition
                        if ( found_start = '0') then
                            -- When the half counter has expired, we're at the middle of the start bit
                            if ( baud_tick_cnt = 0 ) then
                                -- Unlike in the TX core, we do not bother storing the start and stop bits, we just let them
                                -- steer the control path and then store the actual data later
                                if ( uart_rxd_qqq = RX_START_BIT ) then
                                    found_start         <= '1';
                                    -- From this point on, we're going to sample everything one full baud period apart
                                    baud_tick_cnt       <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length);
                                    rx_bit_cnt          <= to_unsigned(1, rx_bit_cnt'length);
                                else
                                    -- Kick us out of looking for the start bit and back to idle
                                    rx_busy             <= '0';
                                end if;
                            else
                                baud_tick_cnt       <= baud_tick_cnt - 1;
                            end if;
                        else
                            -- When the full counter has expired, we're at the middle of a data or stop bit
                            if ( baud_tick_cnt = 0 ) then

                                -- Should be end of frame, so we check to make sure the stop bit is the right value
                                -- and then go back to waiting for next frame
                                if ( rx_bit_cnt = to_unsigned(RX_FRAME_LEN - 1, rx_bit_cnt'length) ) then
                                    -- Frame was good, so we can write to the FIFO
                                    if ( uart_rxd_qqq = RX_STOP_BIT ) then
                                        if (rx_fifo_full = '0' and rx_fifo_ready = '1') then
                                            rx_fifo_wr_data         <= rx_data_sr;
                                            rx_fifo_wr_en           <= '1';
                                            rx_frame_cnt            <= rx_frame_cnt + 1;
                                        else
                                            rx_overflow             <= '1';
                                            rx_frame_err            <= rx_frame_err + 1;
                                        end if;
                                    -- Didn't encounter a stop bit when we should have, so junk this tranmission
                                    -- and return to idle
                                    else
                                        rx_fifo_wr_en           <= '0';
                                        rx_frame_err            <= rx_frame_err + 1;
                                    end if;
                                    -- Back to an idle condition, waiting for the next start bit
                                    rx_busy                 <= '0';

                                else
                                    -- Reset our counter to sample one full baud period later
                                    baud_tick_cnt           <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length);
                                    rx_bit_cnt              <= rx_bit_cnt + 1;
                                    -- The LSB is loaded into the top of the shift register...
                                    rx_data_sr(7)           <= uart_rxd_qqq;
                                    -- ...and then shifted down
                                    rx_data_sr(6 downto 0)  <= rx_data_sr(7 downto 1);
                                end if;

                            else
                                baud_tick_cnt       <= baud_tick_cnt - 1;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    fifo_rx_i0: entity work.fifo_sync
    generic map (
        DEVICE          => DEVICE,
        FIFO_WIDTH      => 8,
        FIFO_SIZE       => "18Kb",
        FWFT            => false,
        DO_REG          => DO_REG,
        DEBUG           => false
    )
    port map (
        clk             => clk,
        rst             => rst,
        wr_en           => rx_fifo_wr_en,
        wr_data         => rx_fifo_wr_data,
        rd_en           => rx_fifo_rd_en,
        rd_data         => rx_fifo_rd_data,
        ready           => rx_fifo_ready,
        full            => rx_fifo_full,
        empty           => rx_fifo_empty
    );

    skid_buffer_rx: entity work.skid_buffer
    generic map (
        DATA_WIDTH      => 8,
        DO_REG          => DO_REG
    )
    port map (
        clk             => clk,
        rst             => rst,
        fifo_rd_data    => rx_fifo_rd_data,
        fifo_rd_en      => rx_fifo_rd_en,
        fifo_empty      => rx_fifo_empty,
        fifo_ready      => rx_fifo_ready,
        rd_data         => rd_data,
        rd_valid        => rd_valid,
        rd_ready        => rd_ready
    );

end architecture behavioral;

