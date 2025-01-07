library ieee;
use ieee.std_logic_1164.all;

entity skid_buffer is
    generic (
        -- Data width should generally match the FIFO we are connected to
        DATA_WIDTH      : natural       := 8;
        -- Indicate whether FIFO we are reading from has an additional pipeline register. When set
        -- to 0, the skid buffer assumes one clock of latency between the assertion of the FIFO read
        -- enable and when data is available on the input. When set to 1, the expectation is that
        -- two clocks of latency are required. The intent is that this generic matches the value of
        -- the `DO_REG` generic that is commonly used
        DO_REG          : natural       := 1
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        fifo_rd_data    : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        fifo_rd_en      : out   std_logic := '0';
        fifo_empty      : in    std_logic;
        fifo_ready      : in    std_logic;

        rd_data         : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_valid        : out   std_logic := '0';
        rd_ready        : in    std_logic

    );
end entity skid_buffer;

architecture behavioral of skid_buffer is

    -- Depending on whether the FIFO has an additional pipelining stage, we create two
    -- separate paths.  When the additional pipeline stage is present, data follows this path:
    --
    --      fifo_rd_valid_i -> fifo_rd_valid -> (skid_valid) -> rd_valid
    --
    --  If the additional pipeline stage is not present, then data follows this path instead:
    --
    --      fifo_rd_valid   -> (skid_valid) -> rd_valid
    --
    -- Data is generally read from the FIFO when the FIFO is ready and non-empty, and the
    -- pipeline is able to consume it. If data is ready at the output but the consumer is not ready, then
    -- data is temporarily stored in the skid register and the read pipeline halts.

    signal fifo_rd_valid_i          : std_logic;
    signal fifo_rd_valid            : std_logic;
    signal skid_valid               : std_logic;
    signal skid_data                : std_logic_vector((DATA_WIDTH -1) downto 0);

begin

    -- Only read from the FIFO when it is ready, non-empty and we have a spot to put the
    -- data on the next clock cycle
    fifo_rd_en  <= '0' when (fifo_empty = '1' or fifo_ready = '0') else
                   -- These first two signals are not strictly required, but are retained for
                   -- clarity (first condition makes them unnecessarily redundant). Confirmed
                   -- that synthesis result is the same without the redundant check.
                   '1' when (fifo_empty = '0' and fifo_ready = '1' and ((rd_valid = '0') or (rd_valid = '1' and rd_ready = '1'))) else
                   '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                -- Resetting the FIFO read valid signals unnecessarily complicates the clock enable
                -- to the `rd_data` register and does not need to be done explicitly.
                skid_valid      <= '0';
                rd_valid        <= '0';
            else
                -- The intent of this conditional is that the `fifo_rd_valid` tracks with the
                -- `fifo_rd_data` for both the pipelined and non-pipelined cases. When DO_REG is 0,
                -- the unnecessary logic should get pruned away by synthesis.
                if (DO_REG = 1) then
                    -- For the pipelined FIFO case, we construct the state of the internal FIFO
                    -- output stage here first.
                    if (fifo_rd_en = '1') then
                        fifo_rd_valid_i     <= '1';
                    -- Not reading from the FIFO (not necessearily because the pipeline halted, the FIFO
                    -- could be empty too), so the data at the FIFO output before the pipeline
                    -- register is going to get consumed if there is a place for it or if data can move
                    elsif (fifo_rd_valid = '0' or rd_valid = '0' or (rd_valid = '1' and rd_ready = '1')) then
                        fifo_rd_valid_i     <= '0';
                    end if;

                    -- Then register it again as valid
                    fifo_rd_valid       <= fifo_rd_valid_i;
                else
                    -- The non-pipelined FIFO case is simpler
                    if (fifo_rd_en = '1') then
                        fifo_rd_valid       <= '1';
                    elsif (skid_valid = '0' or rd_valid = '0' or (rd_valid = '1' and rd_ready = '1')) then
                        fifo_rd_valid       <= '0';
                    end if;
                end if;

                -- Data is stored in the skid register when there is valid data at the pipelined output
                -- of the FIFO and data at the output of the component cannot move
                if (skid_valid = '0' and fifo_rd_valid = '1' and (rd_valid = '1' and rd_ready = '0')) then
                    skid_valid          <= '1';
                    skid_data           <= fifo_rd_data;
                elsif (skid_valid = '1' and (rd_valid = '0' or (rd_valid = '1' and rd_ready = '1'))) then
                    skid_valid          <= '0';
                end if;

                -- The pipeline is held if data is at the output and cannot move
                if (rd_valid = '1' and rd_ready = '0') then
                    rd_valid            <= '1';
                    rd_data             <= rd_data;
                -- Data moves if there is space at the end or if data is at the end and can move
                elsif (rd_valid = '0' or (rd_valid = '1' and rd_ready = '1')) then
                    if (skid_valid = '1') then
                        rd_valid            <= '1';
                        rd_data             <= skid_data;
                    elsif (fifo_rd_valid = '1') then
                        rd_valid            <= '1';
                        rd_data             <= fifo_rd_data;
                    else
                        rd_valid            <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

