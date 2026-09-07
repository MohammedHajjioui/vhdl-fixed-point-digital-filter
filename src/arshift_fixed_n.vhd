library ieee;
use ieee.std_logic_1164.all;

entity arshift_fixed_n is
  generic (
    N     : positive := 32;
    SHIFT : natural  := 0
  );
  port (
    X : in  std_logic_vector(N-1 downto 0);
    Y : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of arshift_fixed_n is
  constant SIGN_BIT : integer := N-1;
begin
  gen_bits : for i in 0 to N-1 generate
    -- Y(i) = X(i+SHIFT) se dentro range, altrimenti estensione di segno
    in_range : if (i + SHIFT) <= (N-1) generate
      Y(i) <= X(i + SHIFT);
    end generate;

    out_range : if (i + SHIFT) > (N-1) generate
      Y(i) <= X(SIGN_BIT);
    end generate;
  end generate;
end architecture;
