library ieee;
use ieee.std_logic_1164.all;

entity adder_n is
  generic (
    N : positive := 32
  );
  port (
    A    : in  std_logic_vector(N-1 downto 0);
    B    : in  std_logic_vector(N-1 downto 0);
    CIN  : in  std_logic;
    SUM  : out std_logic_vector(N-1 downto 0);
    COUT : out std_logic
  );
end entity;

architecture rtl of adder_n is
  signal c : std_logic_vector(N downto 0);
begin
  c(0) <= CIN;

  gen_fa : for i in 0 to N-1 generate
    fa_i : entity work.full_adder_1b
      port map (
        A    => A(i),
        B    => B(i),
        CIN  => c(i),
        SUM  => SUM(i),
        COUT => c(i+1)
      );
  end generate;

  COUT <= c(N);
end architecture;
