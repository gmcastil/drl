library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;

entity reg_block is
    generic (
        REG_ADDR_WIDTH      : natural       := 4;
        NUM_REGS            : natural       := 16;
        -- Identifies which registers can be written to from the bus
        REG_WRITE_MASK      : std_logic_vector(15 downto 0) := (others=>'0')
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        reg_addr            : in  unsigned(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : in  std_logic_vector(31 downto 0);
        reg_wren            : in  std_logic;
        reg_be              : in  std_logic_vector(3 downto 0);
        reg_rdata           : out std_logic_vector(31 downto 0);
        reg_req             : in  std_logic;
        reg_ack             : out std_logic;
        reg_err             : out std_logic;

        rd_regs             : in  reg_a(NUM_REGS-1 downto 0);
        wr_regs             : out reg_a(NUM_REGS-1 downto 0)
    );

end entity reg_block;

architecture behavioral of reg_block is

    signal reg_bank         : reg_a(NUM_REGS-1 downto 0);

    signal busy             : std_logic;
    signal reg_err_cnt      : unsigned(31 downto 0);

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                busy            <= '0';

                reg_ack         <= '0';
                reg_err         <= '0';
                reg_err_cnt     <= (others=>'0');

                reg_bank        <= (others=>reg_t'(others=>'0'));
            else
                -- Update all read-only registers from external sources and register output
                -- signals again for timing purposes
                for i in 0 to (NUM_REGS-1) loop
                    if (REG_WRITE_MASK(i) = '0') then
                        reg_bank(i)     <= rd_regs(i);
                    else
                        wr_regs(i)      <= reg_bank(i);
                    end if;
                end loop;

                -- Not servicing a register access
                if (busy = '0') then
                    -- Access requested
                    if (reg_req = '1') then
                        busy        <= '1';
                    end if;
                else
                    -- Read was requested
                    if (reg_wren = '0') then
                        -- Service the register read
                        if (reg_req = '1' and reg_ack = '0') then
                            reg_ack         <= '1';
                            -- The range of available addresses is typically greater than the number
                            -- of registers we actually support (e.g., a 6-bit address bus, but
                            -- only 15 registers).
                            if (reg_addr < NUM_REGS) then
                                reg_rdata       <= reg_bank(to_integer(reg_addr));
                                reg_err         <= '0';
                            else
                                reg_rdata       <= (others=>'1');
                                reg_err         <= '1';
                            end if;
                        -- Terminate the register read
                        elsif (reg_req = '1' and reg_ack = '1') then
                            reg_ack         <= '0';
                            busy            <= '0';
                            if (reg_err = '1') then
                                reg_err_cnt     <= reg_err_cnt + 1;
                            end if;
                            reg_err         <= '0';
                        end if;
                    -- Write requested
                    else
                        if (reg_req = '1' and reg_ack = '0') then
                            reg_ack         <= '1';
                            -- Update writable registers from the interface here
                            if (reg_addr < NUM_REGS and REG_WRITE_MASK(to_integer(reg_addr)) = '1') then
                                -- Applying byte enables
                                if (reg_be(0) = '1') then
                                    reg_bank(to_integer(reg_addr))(7 downto 0) <= reg_wdata(7 downto 0);
                                end if;
                                if (reg_be(1) = '1') then
                                    reg_bank(to_integer(reg_addr))(15 downto 8) <= reg_wdata(15 downto 8);
                                end if;
                                if (reg_be(2) = '1') then
                                    reg_bank(to_integer(reg_addr))(23 downto 16) <= reg_wdata(23 downto 16);
                                end if;
                                if (reg_be(3) = '1') then
                                    reg_bank(to_integer(reg_addr))(31 downto 24) <= reg_wdata(31 downto 24);
                                end if;
                                reg_err         <= '0';
                            else
                                reg_err         <= '1';
                            end if;
                        elsif (reg_req = '1' and reg_ack = '1') then
                            reg_ack         <= '0';
                            busy            <= '0';
                            if (reg_err = '1') then
                                reg_err_cnt     <= reg_err_cnt + 1;
                            end if;
                            reg_err         <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

