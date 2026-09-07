library ieee;
use ieee.std_logic_1164.all;

entity mux2_n is
  generic (
    N : positive := 32
  );
  port (
    SEL : in  std_logic;
    D0  : in  std_logic_vector(N-1 downto 0);
    D1  : in  std_logic_vector(N-1 downto 0);
    Y   : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of mux2_n is
begin
  gen_bits : for i in 0 to N-1 generate
    Y(i) <= (D0(i) and (not SEL)) or (D1(i) and SEL);
  end generate;
end architecture;
