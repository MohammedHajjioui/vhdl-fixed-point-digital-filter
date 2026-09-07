library ieee;
use ieee.std_logic_1164.all;

entity register_n is
  generic (
    N : positive := 32
  );
  port (
    CLK : in  std_logic;
    RST : in  std_logic; 
    EN  : in  std_logic; 
    D   : in  std_logic_vector(N-1 downto 0);
    Q   : out std_logic_vector(N-1 downto 0)
  );
end entity register_n;

architecture rtl of register_n is
  signal r_q : std_logic_vector(N-1 downto 0) := (others => '0');
begin

  process (CLK)
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        r_q <= (others => '0');
      elsif EN = '1' then
        r_q <= D;
      end if;
    end if;
  end process;

  Q <= r_q;

end architecture rtl;
