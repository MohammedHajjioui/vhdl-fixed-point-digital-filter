library ieee;
use ieee.std_logic_1164.all;

entity mux8_n is
  generic (
    N : positive := 32
  );
  port (
    SEL : in  std_logic_vector(2 downto 0);
    D0  : in  std_logic_vector(N-1 downto 0);
    D1  : in  std_logic_vector(N-1 downto 0);
    D2  : in  std_logic_vector(N-1 downto 0);
    D3  : in  std_logic_vector(N-1 downto 0);
    D4  : in  std_logic_vector(N-1 downto 0);
    D5  : in  std_logic_vector(N-1 downto 0);
    D6  : in  std_logic_vector(N-1 downto 0);
    D7  : in  std_logic_vector(N-1 downto 0);
    Y   : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of mux8_n is
  signal l0_0, l0_1, l0_2, l0_3 : std_logic_vector(N-1 downto 0);
  signal l1_0, l1_1             : std_logic_vector(N-1 downto 0);
begin
  -- livello 0: selezione SEL(0)
  m0 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(0), D0 => D0, D1 => D1, Y => l0_0);
  m1 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(0), D0 => D2, D1 => D3, Y => l0_1);
  m2 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(0), D0 => D4, D1 => D5, Y => l0_2);
  m3 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(0), D0 => D6, D1 => D7, Y => l0_3);

  -- livello 1: selezione SEL(1)
  m4 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(1), D0 => l0_0, D1 => l0_1, Y => l1_0);
  m5 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(1), D0 => l0_2, D1 => l0_3, Y => l1_1);

  -- livello 2: selezione SEL(2)
  m6 : entity work.mux2_n generic map (N => N) port map(SEL => SEL(2), D0 => l1_0, D1 => l1_1, Y => Y);
end architecture;
