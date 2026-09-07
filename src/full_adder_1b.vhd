library ieee;
use ieee.std_logic_1164.all;

entity full_adder_1b is
  port (
    A    : in  std_logic;
    B    : in  std_logic;
    CIN  : in  std_logic;
    SUM  : out std_logic;
    COUT : out std_logic
  );
end entity;

architecture rtl of full_adder_1b is
begin
  SUM  <= A xor B xor CIN;
  COUT <= (A and B) or (A and CIN) or (B and CIN);
end architecture;
