library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library unisim;
use unisim.vcomponents.all;

entity fifo_sync is
    generic (
        -- Support for 7SERIES and ULTRASCALE devices
        DEVICE              : string        := "7SERIES";

        -- Width of the input and output FIFO data ports at the top level of the entity and can be
        -- 1-36 when selecting 18Kb FIFO primitive and 1-72 for 36Kb primitives
        FIFO_WIDTH          : natural       := 8;

        -- Can be either 18Kb or 36Kb - note that the FIFO depth is implicitly defined
        -- by the choice of FIFO primitive and desired width of the data ports
        --
        -- FIFO_WIDTH | FIFO_SIZE | BRAM Width | FIFO Depth
        -- ------------------------------------------------
        --    1 - 4   |   18Kb    |    4       |   4096
        --    1 - 4   |   36Kb    |    4       |   8192
        --    5 - 9   |   18Kb    |    8       |   2048
        --    5 - 9   |   36Kb    |    8       |   4096
        --   10 - 18  |   18Kb    |    16      |   1024
        --   10 - 18  |   36Kb    |    16      |   2048
        --   19 - 36  |   18Kb    |    32      |   512
        --   19 - 36  |   36Kb    |    32      |   1024
        --   36 - 72  |   36Kb    |    64      |   512
        --
        FIFO_SIZE           : string        := "18Kb";
        -- Enable first-word fall through behavior (default to standard)
        FWFT                : boolean       := false;
        -- Enable output register
        DO_REG              : natural       := 0;
        -- Enable debug output for simulation purposes
        DEBUG               : boolean       := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;
        wr_en               : in    std_logic;
        wr_data             : in    std_logic_vector((FIFO_WIDTH - 1) downto 0);
        rd_en               : in    std_logic;
        rd_data             : out   std_logic_vector((FIFO_WIDTH - 1) downto 0);
        ready               : out   std_logic;
        full                : out   std_logic;
        empty               : out   std_logic
    );

end entity fifo_sync;

architecture structural of fifo_sync is

    -- Print out a failure message
    procedure print_failure(
        msg         : in string
    ) is
    begin
        assert false
        report "Failure: " & msg
        severity failure;
    end procedure;

    -- Determine FIFO mode value based on the desired user FIFO size and FIFO width.
    function get_fifo_mode(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return string is
    begin
        if (fifo_size = "36Kb") then
            if (fifo_width > 36 and fifo_width <= 72) then
                return "FIFO36_72";
            else
                return "FIFO36";
            end if;
        else
            if (fifo_width > 18 and fifo_width <= 36) then
                return "FIFO18_36";
            else
                return "FIFO18";
            end if;
        end if;
    end function;

    -- Returns the overall maximum width of the FIFO primitive (i.e., data + parity width)
    function get_data_width(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return natural is
        variable data_width : natural;
    begin
        case fifo_width is
            when 0 to 4     => data_width := 4;
            when 5 to 9     => data_width := 9;
            when 10 to 18   => data_width := 18;
            when 19 to 36   => data_width := 36;
            -- For 36Kb only
            when 37 to 72   =>
                if (fifo_size = "36Kb") then
                    data_width      := 72;
                else
                    print_failure("Invalid FIFO_WIDTH for FIFO18 primitive");
                    data_width      := 0;
                end if;
            when others     =>
                print_failure("Invalid FIFO_WIDTH");
                data_width      := 0;
        end case;
        return data_width;
    end function;

    -- Returns the width of the input and output data port to the FIFO primitive
    function get_data_port_width(
        fifo_size : in string
    ) return natural is
    begin
        if (fifo_size = "36Kb") then
            return 64;
        else
            return 32;
        end if;
    end function;

    -- Returns the width of the input and output parity port to the FIFO primitive
    function get_parity_port_width(
        fifo_size : in string
    ) return natural is
    begin
        if (fifo_size = "36Kb") then
            return 8;
        else
            return 4;
        end if;
    end function;

    -- Determines the number of data bits actually available, based on FIFO configuration.
    function get_max_data_width(
        data_width : in natural
    ) return natural is
    begin
        case data_width is
            when 4      => return 4;
            when 9      => return 8;
            when 18     => return 16;
            when 36     => return 32;
            -- For 36Kb FIFO
            when others => return 64;
        end case;
    end function;

    -- Determines the number of parity bits actually available, based on FIFO configuration.
    function get_max_parity_width(
        data_width : natural
    ) return natural is
        variable max_width : natural;
    begin
        case data_width is
            when 4      => return 0;
            when 9      => return 1;
            when 18     => return 2;
            when 36     => return 4;
            -- For 36Kb FIFO
            when others => return 8;
        end case;
    end function;

    -- Determine the number of data bits actually used, based on the FIFO_WIDTH
    function get_used_data_width(
        fifo_width : in natural
    ) return natural is
    begin
        case fifo_width is
            when 9          => return 8;
            when 17 to 18   => return 16;
            when 33 to 36   => return 32;
            when 65 to 72   => return 64;
            when others     => return fifo_width;
        end case;
    end function;

    -- Determine the number of parity bits actually used, based on the FIFO_WIDTH
    function get_used_parity_width(
        fifo_width : in natural
    ) return natural is
    begin
        case fifo_width is
            -- For 1-4 use 4-bit data width, no parity used
            -- For 5-8 use 8-bit data width, no parity used
            when 9          => return 1;
            -- For 10-16 use 16-bit data width, no parity used
            when 17         => return 1;
            when 18         => return 2;
            -- For 19-32 use 32-bit data width, no parity used
            when 33         => return 1;
            when 34         => return 2;
            when 35         => return 3;
            when 36         => return 4;
            -- For 37-64 use 64-bit data width, no parity used
            when 65         => return 1;
            when 66         => return 2;
            when 67         => return 3;
            when 68         => return 4;
            when 69         => return 5;
            when 70         => return 6;
            when 71         => return 7;
            when 72         => return 8;
            -- For the indicated ranges, no parity used
            when others     => return 0;
        end case;
    end function;

    -- FIFO18 and FIFO36 generics (see UG953 and UG974 for details)
    constant FIFO_MODE              : string    := get_fifo_mode(FIFO_SIZE, FIFO_WIDTH);
    -- Desired data width of the FIFO primitive (note that this is equal to the sum of the width of
    -- the BRAM data and parity ports)
    constant DATA_WIDTH             : natural   := get_data_width(FIFO_SIZE, FIFO_WIDTH);

    -- Actual physical data and parity port widths to the FIFO primitive - these are fixed at either
    -- of the two sizes based upon the FIFO primitive.  However, based upon the BRAM configuration
    -- which is determined by the misleadingly named DATA_WIDTH generic, only a subset of the data
    -- port will actually be used (e.g., DATA_WIDTH = 4 with FIFO_SIZE = 36Kb will only use 4 of the
    -- available 64-bits on the data bus).  The parity port is treated similarly, but for many
    -- desired FIFO_WIDTH values will not be used.
    constant DATA_PORT_WIDTH        : natural   := get_data_port_width(FIFO_SIZE);
    constant PARITY_PORT_WIDTH      : natural   := get_parity_port_width(FIFO_SIZE);

    -- Maximum number of bits from the data port available, given the FIFO configuration
    constant MAX_DATA_WIDTH         : natural   := get_max_data_width(DATA_WIDTH);
    -- Maximum number of bits from the parity port available, given the FIFO configuration
    constant MAX_PARITY_WIDTH       : natural   := get_max_parity_width(DATA_WIDTH);

    -- Actual number of data bits used to to represent the desired input FIFO width
    constant USED_DATA_WIDTH        : natural   := get_used_data_width(FIFO_WIDTH);
    -- Actual number of parity bits used to represent the desired input FIFO width
    constant USED_PARITY_WIDTH      : natural   := get_used_parity_width(FIFO_WIDTH);

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset. Xilinx
    -- FIFO primitives have very specific requirements for reset (which are ignored by everyone,
    -- hence newer macros that do it transparently). See 'FIFO Operations' in UG473 for details.
    constant RST_HOLD_CNT           : unsigned(3 downto 0) := x"5";

    -- Print out FIFO generics and configuration constants for debugging purposes - this needs to be
    -- defined after all the constants, so that they are visible to the procedure.
    procedure print_debug_info is
        variable msg : line;
    begin
        -- Building a single message string so that the simulator reports everything at the same
        -- instance without separating them by delta cycles
        write(msg, string'(     "Debug: FIFO_MODE = " & FIFO_MODE));
        write(msg, string'(LF & "Debug: DATA_WIDTH = " & integer'image(DATA_WIDTH)));
        write(msg, string'(LF & "Debug: DATA_PORT_WIDTH = " & integer'image(DATA_PORT_WIDTH)));
        write(msg, string'(LF & "Debug: PARITY_PORT_WIDTH = " & integer'image(PARITY_PORT_WIDTH)));
        write(msg, string'(LF & "Debug: MAX_DATA_WIDTH = " & integer'image(MAX_DATA_WIDTH)));
        write(msg, string'(LF & "Debug: MAX_PARITY_WIDTH = " & integer'image(MAX_PARITY_WIDTH)));
        write(msg, string'(LF & "Debug: USED_DATA_WIDTH = " & integer'image(USED_DATA_WIDTH)));
        write(msg, string'(LF & "Debug: USED_PARITY_WIDTH = " & integer'image(USED_PARITY_WIDTH)));
        writeline(output, msg);
    end procedure;

    signal fifo_rst                 : std_logic := '1';
    signal fifo_rst_done            : std_logic := '0';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;

    -- Output register clock enable and reset
    signal regce                    : std_logic;
    signal regrst                   : std_logic;

    -- These are the actual FIFO input signals, but we will need to populate them appropriately
    -- later based on the data and parity port widths.
    signal fifo_wr_data             : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_wr_parity           : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_data             : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_parity           : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);

begin

    g_debug: if (DEBUG = true) generate
        process
        begin
            print_debug_info;
            wait;
        end process;
    end generate g_debug;

    -- In general, we assume that all generics are provided with acceptable values to make functions
    -- simpler and easier to understand. Conditionals are all written assuming 18Kb is the default
    -- size.  Rather than checking in every function for every combination of generics, we instead
    -- perform assertions here and then charge ahead with the knowledge the instance has been
    -- configured appropriately.
    -- Assert FIFO size was provided correctly
    assert (FIFO_SIZE = "18Kb" or FIFO_SIZE = "36Kb")
        report "Invalid FIFO_SIZE supplied. " &
            "Desired FIFO primitive must be 18Kb or 36Kb."
        severity failure;

    -- Different assertions depending upon the FIFO primitive in use
    g_asserts_36kb: if (FIFO_SIZE = "36Kb") generate
    begin
        assert(FIFO_WIDTH > 0 and FIFO_WIDTH <= 72)
        report "Invalid FIFO_WIDTH supplied. " &
            "Desired FIFO width must be between 1 and 72-bits for 36Kb"
        severity failure;
    end generate g_asserts_36kb;

    g_asserts_18kb: if (FIFO_SIZE = "18Kb") generate
        assert (FIFO_WIDTH > 0 and FIFO_WIDTH <= 36)
        report "Invalid FIFO_WIDTH supplied. " &
            "Desired FIFO width must be between 1 and 36-bits for 36Kb"
        severity failure;
    end generate g_asserts_18kb;

    -- There's a lot of edge cases in this signal slicing which really sucked to get right, so we
    -- assert something intelligent about their relationship. This is an obvious relationship now,
    -- but it wasn't nearly this obvious when I stated this thing.
    assert FIFO_WIDTH = (USED_PARITY_WIDTH + USED_DATA_WIDTH)
        report "FIFO_WIDTH != USED_PARITY_WIDTH + USED_DATA_WIDTH"
        severity failure;

    g_fifo_wr: if (USED_PARITY_WIDTH > 0) generate
        fifo_wr_data((USED_DATA_WIDTH - 1) downto 0)        <= wr_data((USED_DATA_WIDTH - 1) downto 0);
        fifo_wr_parity((USED_PARITY_WIDTH - 1) downto 0)    <= wr_data((FIFO_WIDTH - 1) downto USED_DATA_WIDTH);
    else generate
        fifo_wr_data((USED_DATA_WIDTH - 1) downto 0)        <= wr_data;
        fifo_wr_parity                                      <= (others=>'0');
    end generate g_fifo_wr;

    g_fifo_rd: if (USED_PARITY_WIDTH > 0) generate
        rd_data     <= fifo_rd_parity((USED_PARITY_WIDTH - 1) downto 0) & fifo_rd_data((USED_DATA_WIDTH - 1) downto 0);
    else generate
        rd_data     <= fifo_rd_data((FIFO_WIDTH - 1) downto 0);
    end generate g_fifo_rd;

    -- This is where the FIFO_SYNC_MACRO from the Xilinx UNIMACRO simulation library was wrong
    -- and inadvertently holds the output register in reset when DO_REG is set.
    regce           <= '1' when (DO_REG = 1) else '0';
    regrst          <= '0' when (DO_REG = 1) else '1';

    -- What's that you say?  These don't look like the FIFO primitives you saw in the libraries
    -- guide?  That's because the libraries guide is wrong and apparently the crackhead that wrote
    -- the FIFO wrappers didn't read the source code.  The instantiation templates are not to be
    -- trusted. You have to read the component definitions!!!
    g_fifo_7series: if (DEVICE = "7SERIES") generate
    begin
        -- For 7-series, we carefully curate the reset signal and then use its deassertion as a
        -- ready indicator (for Ultrascale this will likely be different)
        ready       <= fifo_rst_done;

        -- Per the 7-Series Memory Resources User Guide (UG473) section 'FIFO Operations', the
        -- asynchronous FIFO reset should be held high for five read and write clock cycles to ensure
        -- all internal states and flags are reset to the correct values.  During reset, the write and
        -- read enable signals should both be deasserted and remain deasserted until the reset sequence
        -- is complete.
        p_fifo_rst: process (clk)
        begin
            if rising_edge(clk) then
                if (rst = '1') then
                    fifo_rst            <= '1';
                    fifo_rst_done       <= '0';
                    fifo_rst_cnt        <= RST_HOLD_CNT;
               else
                    if fifo_rst = '1' then
                        -- A FIFO reset sequence is complete when the write and read enable signals
                        -- have been deasserted prior to assertion of a reset and have remained deasserted
                        -- for RST_HOLD_CNT clocks
                        if wr_en = '0' and rd_en = '0' and fifo_rst_cnt = 0 then
                            fifo_rst            <= '0';
                            fifo_rst_done       <= '1';
                        else
                            fifo_rst            <= '1';
                            fifo_rst_done       <= '0';
                        end if;

                        -- If either read or write enable are asserted during the reset hold sequence, we
                        -- deassert the reset that we were trying to perform and start all over again.
                        if wr_en = '1' or rd_en = '1' then
                            fifo_rst_cnt        <= RST_HOLD_CNT;
                        else
                            fifo_rst_cnt        <= fifo_rst_cnt - 1;
                        end if;

                    else
                        fifo_rst            <= '0';
                        fifo_rst_cnt        <= RST_HOLD_CNT;
                    end if;
                end if;
            end if;
        end process p_fifo_rst;

        -- Now we can actually instantiate the primitives correctly
        g_fifo_prim: if (FIFO_SIZE = "36Kb") generate
            FIFO36E1_i0: FIFO36E1
            generic map (
                ALMOST_FULL_OFFSET          => X"0080",
                ALMOST_EMPTY_OFFSET         => X"0080",
                DATA_WIDTH                  => DATA_WIDTH,
                DO_REG                      => DO_REG,
                EN_ECC_READ                 => false,
                EN_ECC_WRITE                => false,
                EN_SYN                      => true,
                FIFO_MODE                   => FIFO_MODE,
                FIRST_WORD_FALL_THROUGH     => FWFT,
                INIT                        => X"000000000000000000",
                IS_RDCLK_INVERTED           => '0',
                IS_RDEN_INVERTED            => '0',
                IS_RSTREG_INVERTED          => '0',
                IS_RST_INVERTED             => '0',
                IS_WRCLK_INVERTED           => '0',
                IS_WREN_INVERTED            => '0',
                SIM_DEVICE                  => DEVICE,
                SRVAL                       => X"000000000000000000"
            )
            port map (
                ALMOSTEMPTY                 => open,
                ALMOSTFULL                  => open,
                DBITERR                     => open,
                DO                          => fifo_rd_data,
                DOP                         => fifo_rd_parity,
                ECCPARITY                   => open,
                EMPTY                       => empty,
                FULL                        => full,
                RDCOUNT                     => open,
                RDERR                       => open,
                SBITERR                     => open,
                WRCOUNT                     => open,
                WRERR                       => open,
                DI                          => fifo_wr_data,
                DIP                         => fifo_wr_parity,
                INJECTDBITERR               => '0',
                INJECTSBITERR               => '0',
                RDCLK                       => clk,
                RDEN                        => rd_en,
                REGCE                       => regce,
                RST                         => fifo_rst,
                RSTREG                      => regrst,
                WRCLK                       => clk,
                WREN                        => wr_en
            );

        elsif (FIFO_SIZE = "18Kb") generate
            FIFO18E1_i0: FIFO18E1
            generic map (
                ALMOST_EMPTY_OFFSET         => X"0080",
                ALMOST_FULL_OFFSET          => X"0080",
                DATA_WIDTH                  => DATA_WIDTH,
                DO_REG                      => DO_REG,
                EN_SYN                      => true,
                FIFO_MODE                   => FIFO_MODE,
                FIRST_WORD_FALL_THROUGH     => FWFT,
                INIT                        => X"000000000",
                IS_RDCLK_INVERTED           => '0',
                IS_RDEN_INVERTED            => '0',
                IS_RSTREG_INVERTED          => '0',
                IS_RST_INVERTED             => '0',
                IS_WRCLK_INVERTED           => '0',
                IS_WREN_INVERTED            => '0',
                SIM_DEVICE                  => DEVICE,
                SRVAL                       => X"000000000"
            )
            port map (
                ALMOSTEMPTY                 => open,
                ALMOSTFULL                  => open,
                DO                          => fifo_rd_data,
                DOP                         => fifo_rd_parity,
                EMPTY                       => empty,
                FULL                        => full,
                RDCOUNT                     => open,
                RDERR                       => open,
                WRCOUNT                     => open,
                WRERR                       => open,
                DI                          => fifo_wr_data,
                DIP                         => fifo_wr_parity,
                RDCLK                       => clk,
                RDEN                        => rd_en,
                REGCE                       => regce,
                RST                         => fifo_rst,
                RSTREG                      => regrst,
                WRCLK                       => clk,
                WREN                        => wr_en
            );
        end generate g_fifo_prim;
    end generate g_fifo_7series;

end architecture structural;
