library ieee;
use ieee.std_logic_1164.all;

entity term_summer is
  generic (N : positive := 32);
  port (
    T1     : in  std_logic_vector(N-1 downto 0);
    T2     : in  std_logic_vector(N-1 downto 0);
    T3     : in  std_logic_vector(N-1 downto 0);
    Y_NEXT : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture structural of term_summer is
  signal sum_12 : std_logic_vector(N-1 downto 0);
  signal c1, c2 : std_logic;
begin

  add_12 : entity work.adder_n
    generic map (N => N)
    port map (
      A    => T1,
      B    => T2,
      CIN  => '0',
      SUM  => sum_12,
      COUT => c1
    );

  add_123 : entity work.adder_n
    generic map (N => N)
    port map (
      A    => sum_12,
      B    => T3,
      CIN  => '0',
      SUM  => Y_NEXT,
      COUT => c2
    );

end architecture;
