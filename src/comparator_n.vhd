library ieee;
use ieee.std_logic_1164.all;

entity comparator_n is
  generic (
    N : positive := 3
  );
  port (
    A   : in  std_logic_vector(N-1 downto 0);
    B   : in  std_logic_vector(N-1 downto 0);
    NEQ : out std_logic  -- '1' if A ≠ B
  );
end entity comparator_n;

architecture structural of comparator_n is
  signal xor_bits : std_logic_vector(N-1 downto 0);
begin

  -- Generate N XOR gates (bit-wise comparison)
  gen_xor: for i in 0 to N-1 generate
    xor_bits(i) <= A(i) xor B(i);
  end generate;

  -- OR all XOR outputs: NEQ = '1' if any bit differs
  process(xor_bits)
    variable or_result : std_logic;
  begin
    or_result := '0';
    for i in 0 to N-1 loop
      or_result := or_result or xor_bits(i);
    end loop;
    NEQ <= or_result;
  end process;

end architecture structural;
