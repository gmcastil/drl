library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        DEVICE              : string            := "7SERIES"
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        tx_en           : in    std_logic;

        -- Baud rate tick from baud rate generator
        baud_tick       : in    std_logic;

        parity          : in    std_logic_vector(1 downto 0);
        nbstop          : in    std_logic_vector(1 downto 0);
        char            : in    std_logic_vector(1 downto 0);

        -- UART TX data interface
        tx_data         : in    std_logic_vector(7 downto 0);
        tx_valid        : in    std_logic;
        tx_ready        : out   std_logic;

        -- Number of frames sent since the last reset
        tx_frame_cnt    : out   unsigned(31 downto 0);

        -- This may need some modification so that it powers up to a 1 prior to reset. Confirm in
        -- hardware that there is a flop driving this that gets INIT = 1
        uart_txd        : out   std_logic   := '1'
    );

end entity uart_tx;

architecture behavioral of uart_tx is

    -- Enable the FIFO output stage register
    constant DO_REG                 : natural   := 1;

    -- Transmission data register (TDR)
    signal  tx_data_sr              : std_logic_vector((TX_FRAME_LEN - 1) downto 0);
    -- Number of bits to be sent per frame
    signal  tx_bit_cnt              : unsigned(3 downto 0);

    -- Have stored the byte to send and are busy shifting out a frame
    signal  tx_busy                 : std_logic;
    -- Shift register is finished with a frame
    signal  tx_done                 : std_logic;

    signal  tx_data                 : std_logic_vector(7 downto 0);
    signal  tx_valid                : std_logic;
    signal  tx_ready                : std_logic;

    signal  baud_tick_q             : std_logic;
    signal  baud_tick_qq            : std_logic;
    signal  baud_tick_red           : std_logic;

    -- Internal FIFO control signals
    signal  tx_fifo_wr_en           : std_logic;
    signal  tx_fifo_wr_data         : std_logic_vector(7 downto 0);
    signal  tx_fifo_rd_en           : std_logic;
    signal  tx_fifo_rd_data         : std_logic_vector(7 downto 0);
    signal  tx_fifo_ready           : std_logic;
    signal  tx_fifo_full            : std_logic;
    signal  tx_fifo_empty           : std_logic;

begin

    -- Need a rising edge detector for the signal from the baud rate generator
    p_baud_tick_red: process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                baud_tick_q     <= '0';
                baud_tick_qq    <= '0';
                baud_tick_red   <= '0';
            else
                baud_tick_q     <= baud_tick;
                baud_tick_qq    <= baud_tick_q;
                if (baud_tick_q = '1' and baud_tick_qq = '0') then
                    baud_tick_red       <= '1';
                else
                    baud_tick_red       <= '0';
                end if;
            end if;
        end if;
    end process p_baud_tick_red;

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                -- This should initialize to 1 and if we reset the module, needs to
                -- be reset to the same value, or we'll send junk to the receiver
                uart_txd        <= '1';

                -- Busy or done serializing a word pulled from the FIFO
                tx_busy         <= '0';
                tx_done         <= '0';

                tx_ready        <= '0';

                tx_bit_cnt      <= (others=>'0');
                tx_frame_cnt    <= (others=>'0');

            else
                if (tx_busy = '0') then
                    -- Store data when it's available
                    if (tx_fifo_ready = '1' and tx_valid = '1' and tx_ready = '1') then
                        tx_busy         <= '1';
                        tx_ready        <= '0';

                        -- Add start and stop bits to the data byte to write and store
                        -- in the shift register so we can start writing later
                        tx_data_sr      <= TX_STOP_BIT & tx_data & TX_START_BIT;
                        tx_bit_cnt      <= to_unsigned((TX_FRAME_LEN - 1), tx_bit_cnt'length);
                    else
                        tx_ready        <= '1';
                    end if;

                else
                    -- Now, on the baud tick, shift out one bit until done
                    if (baud_tick_red = '1') then
                        if (tx_done = '1') then
                            tx_busy                     <= '0';
                            tx_done                     <= '0';
                            -- Asserting that we're ready for data now saves us a clock
                            -- of idle time
                            tx_ready                    <= '1';
                            tx_frame_cnt                <= tx_frame_cnt + 1;
                        else
                            tx_data_sr(8 downto 0)      <= tx_data_sr(9 downto 1);
                            uart_txd                    <= tx_data_sr(0);

                            tx_bit_cnt                  <= tx_bit_cnt - 1;
                            if (tx_bit_cnt = 0) then
                                tx_done                 <= '1';
                            else
                                tx_done                 <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;


end architecture behavioral;

    -- -- Write to the FIFO when we are not in reset, the producer has valid data, the FIFO is not
    -- -- full, and the FIFO is not in reset.
    -- p_fifo_write: process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         if (rst = '1') then
    --             wr_ready            <= '0';
    --             tx_fifo_wr_en       <= '0';
    --         else
    --             if (wr_valid = '1' and tx_fifo_full = '0' and tx_fifo_ready = '1') then
    --                 wr_ready            <= '1';
    --                 tx_fifo_wr_en       <= '1';

    --                 tx_fifo_wr_data     <= wr_data;
    --             else
    --                 wr_ready            <= '0';
    --                 tx_fifo_wr_en       <= '0';
    --             end if;
    --         end if;
    --     end if;
    -- end process p_fifo_write;
