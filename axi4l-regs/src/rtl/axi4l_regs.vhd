-----------------------------------------------------------------------------
--! @file       axi4l_regs.vhdl
--! @brief      AXI4-Lite to register bank interface
--! @author     George Castillo
--! @date       24 December 2024
--
--! @details
--

    -- Design notes: - The AXI bridge should complete reads and writes successfully when the address is in the
    --     range acceptable to the slave.  If an access to a location is requested that we cannot
    --     service, then we indicate a DECERR Writes to read only locations are ignored.  Transactions
    --     to unaligned addresses also yield a DECERR.
    --   - The AXI bridge should complete reads and writes but indicate errors in the response
    --     when attempting to write a value that is not writeable.
    --   - All register access is handled in this module (i.e., if register access is made on the
    --     register interface, it is expected to complete)
    --   - Register access is centralized in this module because it already has to be done to
    --     conform to the AXI spec and it register access in the internal register block, which makes
    --     implementing it something like BRAM easier later
    --   - Addresses get converted to unsigned internally so we can start using them to do math on
    --     like subtracting base addresses, shifting, etc. and then back to standard logic at the
    --     edges
    --   - Addresses are unsigned values generally, except for the top level interface port
    --     std_logic_vector. This allows boundary base offset and range checking.
    --   - Correct and incorrect (i.e., error) transaction counts are increments at the end of each
    --     read or write transaction. No total counts are available, just good and bad.
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity axi4l_regs is
    generic (
        -- Base address of AXI4-Lite slave in the system
        BASE_OFFSET         : unsigned(31 downto 0) := x"00000000";
        -- Addressable range of the slave (must indicate a power of 2)
        BASE_OFFSET_MASK    : unsigned(31 downto 0) := x"00000FFF";
        -- Width of the register interface bus
        REG_ADDR_WIDTH      : natural               := 4
    );
    port (
        --! @brief All signals are assumed to be synchronous to the input clock
        clk                 : in  std_logic;
        --! @brief Active low reset
        rstn                : in  std_logic;

        --! @brief AXI4-Lite slave interface
        s_axi_awaddr        : in  std_logic_vector(31 downto 0);
        s_axi_awvalid       : in  std_logic;
        s_axi_awready       : out std_logic;

        s_axi_wdata         : in  std_logic_vector(31 downto 0);
        s_axi_wstrb         : in  std_logic_vector(3 downto 0);
        s_axi_wvalid        : in  std_logic;
        s_axi_wready        : out std_logic;

        s_axi_bresp         : out std_logic_vector(1 downto 0);
        s_axi_bvalid        : out std_logic;
        s_axi_bready        : in  std_logic;

        s_axi_araddr        : in  std_logic_vector(31 downto 0);
        s_axi_arvalid       : in  std_logic;
        s_axi_arready       : out std_logic;

        s_axi_rdata         : out std_logic_vector(31 downto 0);
        s_axi_rresp         : out std_logic_vector(1 downto 0);
        s_axi_rvalid        : out std_logic;
        s_axi_rready        : in  std_logic;

        --! @brief Interface to register block. Note that all register signals are on the same domain.
        reg_addr            : out unsigned(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : out std_logic_vector(31 downto 0);
        reg_wren            : out std_logic;
        reg_be              : out std_logic_vector(3 downto 0);
        reg_rdata           : in  std_logic_vector(31 downto 0);
        reg_req             : out std_logic;
        reg_ack             : in  std_logic;
        reg_err             : in  std_logic
    );

end entity axi4l_regs;

architecture behavioral of axi4l_regs is

    constant RESP_OKAY          : std_logic_vector(1 downto 0) := b"00";
    constant RESP_EXOKAY        : std_logic_vector(1 downto 0) := b"01";
    constant RESP_SLVERR        : std_logic_vector(1 downto 0) := b"10";
    constant RESP_DECERR        : std_logic_vector(1 downto 0) := b"11";

    signal  rd_addr             : unsigned(31 downto 0);
    signal  wr_addr             : unsigned(31 downto 0);
    signal  rd_busy             : std_logic;
    signal  wr_busy             : std_logic;
    signal  wr_txn_cnt          : unsigned(31 downto 0);
    signal  wr_err_cnt          : unsigned(31 downto 0);
    signal  rd_txn_cnt          : unsigned(31 downto 0);
    signal  rd_err_cnt          : unsigned(31 downto 0);

    -- Returns true if address is aligned and within range servicable by the slave
    function can_service(addr : unsigned(31 downto 0)) return boolean is
        constant MAX_ADDR : unsigned := BASE_OFFSET + BASE_OFFSET_MASK + 1;
    begin
        if ((addr < BASE_OFFSET) or (addr >= MAX_ADDR)) then
            return false;
        end if;
        if (addr(1 downto 0) = 0) then
            return true;
        else
            return false;
        end if;
    end function;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                s_axi_arready       <= '0';
                s_axi_rvalid        <= '0';
                s_axi_rresp         <= (others=>'0');

                s_axi_awready       <= '0';
                s_axi_wready        <= '0';

                s_axi_bvalid        <= '0';
                s_axi_bresp         <= (others=>'0');

                rd_busy             <= '0';
                wr_busy             <= '0';
                
                reg_req             <= '0';
                reg_wren            <= '0';
            else

                -- Because the register interface does not support concurrent read and write access,
                -- but AXI does, an arbitration scheme is necessary. A naive approach would be to
                -- use the write and ready busy flags as locked indicators. That has the problem of
                -- a read and write arriving at the same time or a read transaction arriving between
                -- the data and address portions of a write transaction.  An alternate approach
                -- would be to create a combinatorial locked indicator based on the control signals,
                -- which has obvious shortcomings as well.
                --
                -- The chosen method of arbitration operates by:
                --   * Using the read and write buys signals to drive two independent state machines
                --     which provide register access
                --   * We decide which path to proceed along based on AXI valid signals
                --
                -- This creates an arbitration scheme with the following features:
                --   * Write transactions are prioritized over read transactions.
                --   * No fairness or scheduling mechanism is implemented; writes can monopolize the bus.
                --   * Write transactions will only proceed when both the address and data are valid 
                --     together. Address and data may still arrive at different times, but the write
                --     transaction will not commence until both signals are valid concurrently.
                --
                if (wr_busy = '0' and rd_busy = '0') then
                    -- We only proceed with a write when both write address and data are present
                    -- together, so we mark ourselves busy now and the register all of the
                    -- transaction details here
                    if (s_axi_awvalid = '1' and s_axi_wvalid = '1') then
                        wr_busy             <= '1';

                        s_axi_awready       <= '1';
                        s_axi_wready        <= '1';

                        -- Do not apply the base offset mask yet because we need to determine if we can
                        -- service the address on the wire first
                        wr_addr             <= unsigned(s_axi_awaddr);
                        reg_wdata           <= s_axi_wdata;
                        reg_be              <= s_axi_wstrb;

                    -- Otherwise a read can get through if it was provided at the same time, so we
                    -- register those details and mark ourselves busy with a read
                    elsif (s_axi_arvalid = '1' ) then
                        rd_busy             <= '1';

                        s_axi_arready       <= '1';

                        -- Again we register the entire address so that we can determine if its
                        -- sericeable before we try to access it
                        rd_addr             <= unsigned(s_axi_araddr);
                    end if;
                end if;

                -- We can use the two busy indicators as proxies for valid and ready being true
                -- together, so we can deassert the ready signals based on that indicator
                if (wr_busy = '1') then
                    s_axi_awready       <= '0';
                    s_axi_wready        <= '0';
                end if;
                if (rd_busy = '1') then
                    s_axi_arready       <= '0';
                end if;

                -- Have an AXI read transaction with registered address to process
                if (rd_busy = '1') then
                    -- AXI address is aligned and within the range servicable by the slave
                    if can_service(rd_addr) then
                        -- Have not asserted valid data to the master yet
                        if (s_axi_rvalid = '0') then
                            -- Have not requested a read from the register bank yet
                            if (reg_req = '0') then
                                reg_req             <= '1';
                                reg_addr            <= resize((rd_addr and BASE_OFFSET_MASK) srl 2, REG_ADDR_WIDTH);
                            -- Register bank responded
                            elsif (reg_req = '1' and reg_ack = '1') then
                                reg_req             <= '0';
                                s_axi_rvalid        <= '1';
                                if (reg_err = '1') then
                                    s_axi_rresp         <= RESP_SLVERR;
                                else
                                    s_axi_rdata         <= reg_rdata;
                                    s_axi_rresp         <= RESP_OKAY;
                                end if;
                            end if;
                        -- AXI read response handshake is complete
                        elsif (s_axi_rvalid = '1' and s_axi_rready = '1') then
                            s_axi_rvalid        <= '0';
                            rd_busy             <= '0';
                        end if;
                    -- Not an AXI address we can service
                    else
                        -- Have not asserted valid to the master yet
                        if (s_axi_rvalid = '0') then
                            s_axi_rvalid        <= '1';
                            s_axi_rresp         <= RESP_DECERR;
                        -- AXI read response handshake is complete
                        elsif (s_axi_rvalid = '1' and s_axi_rready = '1') then
                            s_axi_rvalid        <= '0';
                            rd_busy             <= '0';
                        end if;
                    end if;
                end if;

                -- Have an AXI write transaction with registered address, data, and strobes to process
                if (wr_busy = '1') then
                    -- AXI address is aligned and within the range serviceable by the slave
                    if can_service(wr_addr) then
                        -- Have not asserted valid response to the master yet
                        if (s_axi_bvalid = '0') then
                            -- Have not requested a write to the register bank yet
                            if (reg_req = '0') then
                                reg_req         <= '1';
                                reg_wren        <= '1';
                                reg_addr        <= resize((wr_addr and BASE_OFFSET_MASK) srl 2, REG_ADDR_WIDTH);
                            -- Register bank responded
                            elsif (reg_req = '1' and reg_ack = '1') then
                                reg_req         <= '0';
                                reg_wren        <= '0';
                                s_axi_bvalid    <= '1';
                                if (reg_err = '1') then
                                    s_axi_bresp     <= RESP_SLVERR;
                                else
                                    s_axi_bresp     <= RESP_OKAY;
                                end if;
                            end if;
                        -- AXI write response is complete
                        elsif (s_axi_bvalid = '1' and s_axi_bready = '1') then
                            s_axi_bvalid    <= '0';
                            wr_busy         <= '0';
                        end if;
                    -- Not an AXI address we can service
                    else
                        if (s_axi_bvalid = '0') then
                            s_axi_bvalid        <= '1';
                            s_axi_bresp         <= RESP_DECERR;
                        elsif (s_axi_bvalid = '1' and s_axi_bready = '1') then
                            s_axi_bvalid        <= '0';
                            wr_busy             <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    txn_cnts: process(clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                rd_txn_cnt          <= (others=>'0');
                rd_err_cnt          <= (others=>'0');
                wr_txn_cnt          <= (others=>'0');
                wr_err_cnt          <= (others=>'0');
            else

                -- Count good and bad read transactions
                if (s_axi_rvalid = '1' and s_axi_rready = '1') then
                    if (s_axi_rresp = RESP_OKAY) then
                        rd_txn_cnt          <= rd_txn_cnt + 1;
                    else
                        rd_err_cnt          <= rd_err_cnt + 1;
                    end if;
                end if;

                -- Count good and bad write transactions
                if (s_axi_bvalid = '1' and s_axi_bready = '1') then
                    if (s_axi_bresp = RESP_OKAY) then
                        wr_txn_cnt          <= wr_txn_cnt + 1;
                    else
                        wr_err_cnt          <= wr_err_cnt + 1;
                    end if;
                end if;

            end if;
        end if;
    end process txn_cnts;

end architecture behavioral;

