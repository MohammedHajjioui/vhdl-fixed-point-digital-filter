library ieee;
use ieee.std_logic_1164.all;

entity subtractor_n is
  generic (
    N : positive := 32
  );
  port (
    A    : in  std_logic_vector(N-1 downto 0);
    B    : in  std_logic_vector(N-1 downto 0);
    DIFF : out std_logic_vector(N-1 downto 0);
    COUT : out std_logic
  );
end entity;

architecture rtl of subtractor_n is
  signal b_inv : std_logic_vector(N-1 downto 0);
begin
  b_inv <= not B;

  add_as_sub : entity work.adder_n
    generic map (N => N)
    port map (
      A    => A,
      B    => b_inv,
      CIN  => '1',
      SUM  => DIFF,
      COUT => COUT
    );
end architecture;
