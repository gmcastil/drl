library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_rate_gen is
    port (
        -- Clock and synchronous reset
        clk             : in    std_logic;
        rst             : in    std_logic;

        baud_gen_en     : in    std_logic;
        baud_div        : in    unsigned(14 downto 0);
        baud_cnt        : out   unsigned(14 downto 0);

        baud_tick       : out   std_logic
    );

end entity baud_rate_gen;

architecture behavioral of baud_rate_gen is

    signal baud_div_q   : unsigned(14 downto 0);

begin

    -- Register the input signal baud divisor
    process(clk)
    begin
        if rising_edge(clk) then
            baud_div_q      <= baud_div;
        end if;
    end process;

    -- Generate a one-clock wide baud tick when enabled. The enable
    -- signal serves as a reset to the baud rate generator and
    -- essentially resets the counter
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                baud_tick       <= '0';
                baud_cnt        <= (others=>'0');
            else
                if (baud_gen_en = '1') then
                    if (baud_cnt = baud_div_q) then
                        baud_tick       <= '1';
                        baud_cnt        <= (others=>'0');
                    else
                        baud_tick       <= '0';
                        baud_cnt        <= baud_cnt + 1;
                    end if;
                else
                    baud_tick       <= '0';
                    baud_cnt        <= (others=>'0');
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

