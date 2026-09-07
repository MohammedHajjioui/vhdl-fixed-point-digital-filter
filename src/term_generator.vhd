library ieee;
use ieee.std_logic_1164.all;

entity term_generator is
  generic (
    N : positive := 32
  );
  port (
    K  : in  std_logic_vector(2 downto 0);        -- 0..7
    X  : in  std_logic_vector(N-1 downto 0);      -- Q16.16 two's complement
    Y1 : in  std_logic_vector(N-1 downto 0);      -- Y(t-1)
    Y2 : in  std_logic_vector(N-1 downto 0);      -- Y(t-2)
    
    -- Valori salvati dal ciclo precedente (da state_register)
    Y1_SHIFT_K_SAVED : in std_logic_vector(N-1 downto 0);  -- Y1(t-1)>>k = Y2(t)>>k
    T2_SAVED         : in std_logic_vector(N-1 downto 0);  -- T2(t-1)
    
    -- Output terms
    T1 : out std_logic_vector(N-1 downto 0);      -- X >> k
    T2 : out std_logic_vector(N-1 downto 0);      -- (Y1 >> k) - (Y1 >> 2k)
    T3 : out std_logic_vector(N-1 downto 0);      -- Y2 - Y1>>k* - T2*
    
    -- Valori da salvare per il prossimo ciclo
    Y1_SHIFT_K_OUT : out std_logic_vector(N-1 downto 0)   -- Y1>>k appena calcolato
  );
end entity;

architecture structural of term_generator is
  constant ZERO_V : std_logic_vector(N-1 downto 0) := (others => '0');
  constant K_ZERO : std_logic_vector(2 downto 0) := "000";

  signal k_neq_zero : std_logic;  -- K ≠ 0
  signal is_k0      : std_logic;  -- K = 0

  -- X >> k 
  signal x_s0, x_s1, x_s2, x_s3, x_s4, x_s5, x_s6, x_s7 : std_logic_vector(N-1 downto 0);
  signal x_shift_k : std_logic_vector(N-1 downto 0);

  -- Y1 >> k 
  signal y1_s0, y1_s1, y1_s2, y1_s3, y1_s4, y1_s5, y1_s6, y1_s7 : std_logic_vector(N-1 downto 0);
  signal y1_shift_k : std_logic_vector(N-1 downto 0);

  -- Y1 >> 2k 
  signal y1_2k_s0, y1_2k_s1, y1_2k_s2, y1_2k_s3, y1_2k_s4, y1_2k_s5, y1_2k_s6, y1_2k_s7 : std_logic_vector(N-1 downto 0);
  signal y1_shift_2k : std_logic_vector(N-1 downto 0);

  signal t2_raw : std_logic_vector(N-1 downto 0);

  -- T3 optimization: use saved values
  signal y2_minus_y1k : std_logic_vector(N-1 downto 0);
  signal t3_raw       : std_logic_vector(N-1 downto 0);

  signal c_dummy1, c_dummy2, c_dummy3 : std_logic;
begin
  -- k == 0 ?
  cmp_k_zero : entity work.comparator_n
    generic map (N => 3)
    port map (
      A   => K,
      B   => K_ZERO,
      NEQ => k_neq_zero
    );
  
  is_k0 <= not k_neq_zero;

  --------------------------------------------------------------------------
  -- T1: X >> k  
  x_s0 <= X;  -- no instance, just wire
  xs1 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 1) port map(X => X, Y => x_s1);
  xs2 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 2) port map(X => X, Y => x_s2);
  xs3 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 3) port map(X => X, Y => x_s3);
  xs4 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 4) port map(X => X, Y => x_s4);
  xs5 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 5) port map(X => X, Y => x_s5);
  xs6 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 6) port map(X => X, Y => x_s6);
  xs7 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 7) port map(X => X, Y => x_s7);

  xsel : entity work.mux8_n
    generic map(N => N)
    port map(
      SEL => K,
      D0  => x_s0, D1 => x_s1, D2 => x_s2, D3 => x_s3,
      D4  => x_s4, D5 => x_s5, D6 => x_s6, D7 => x_s7,
      Y   => x_shift_k
    );

  T1 <= x_shift_k;

  --------------------------------------------------------------------------
  -- T2: (Y1 >> k) - (Y1 >> 2k)
  -- Y1 >> k
  y1_s0 <= Y1;  -- no instance
  y1s1 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 1) port map(X => Y1, Y => y1_s1);
  y1s2 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 2) port map(X => Y1, Y => y1_s2);
  y1s3 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 3) port map(X => Y1, Y => y1_s3);
  y1s4 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 4) port map(X => Y1, Y => y1_s4);
  y1s5 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 5) port map(X => Y1, Y => y1_s5);
  y1s6 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 6) port map(X => Y1, Y => y1_s6);
  y1s7 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 7) port map(X => Y1, Y => y1_s7);

  y1sel : entity work.mux8_n
    generic map(N => N)
    port map(
      SEL => K,
      D0  => y1_s0, D1 => y1_s1, D2 => y1_s2, D3 => y1_s3,
      D4  => y1_s4, D5 => y1_s5, D6 => y1_s6, D7 => y1_s7,
      Y   => y1_shift_k
    );

  -- Y1 >> 2k 
  y1_2k_s0 <= Y1;  -- no instance
  y12k1 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 2)  port map(X => Y1, Y => y1_2k_s1);
  y12k2 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 4)  port map(X => Y1, Y => y1_2k_s2);
  y12k3 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 6)  port map(X => Y1, Y => y1_2k_s3);
  y12k4 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 8)  port map(X => Y1, Y => y1_2k_s4);
  y12k5 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 10) port map(X => Y1, Y => y1_2k_s5);
  y12k6 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 12) port map(X => Y1, Y => y1_2k_s6);
  y12k7 : entity work.arshift_fixed_n generic map(N => N, SHIFT => 14) port map(X => Y1, Y => y1_2k_s7);

  y12ksel : entity work.mux8_n
    generic map(N => N)
    port map(
      SEL => K,
      D0  => y1_2k_s0, D1 => y1_2k_s1, D2 => y1_2k_s2, D3 => y1_2k_s3,
      D4  => y1_2k_s4, D5 => y1_2k_s5, D6 => y1_2k_s6, D7 => y1_2k_s7,
      Y   => y1_shift_2k
    );

  -- T2 = (Y1>>k) - (Y1>>2k)
  sub_t2 : entity work.subtractor_n
    generic map(N => N)
    port map(
      A    => y1_shift_k,
      B    => y1_shift_2k,
      DIFF => t2_raw,
      COUT => c_dummy1
    );

  -- if k=0 => T2 = 0
  t2_gate : entity work.mux2_n
    generic map(N => N)
    port map(
      SEL => is_k0,
      D0  => t2_raw,
      D1  => ZERO_V,
      Y   => T2
    );

  -- Output Y1>>k per salvarlo nel state_register
  Y1_SHIFT_K_OUT <= y1_shift_k;
  
  -- Primo step: Y2 - Y1_SHIFT_K_SAVED
  sub_t3_step1 : entity work.subtractor_n
    generic map(N => N)
    port map(
      A    => Y2,
      B    => Y1_SHIFT_K_SAVED,
      DIFF => y2_minus_y1k,
      COUT => c_dummy2
    );

  -- Secondo step: (Y2 - Y1>>k*) - T2*
  sub_t3_step2 : entity work.subtractor_n
    generic map(N => N)
    port map(
      A    => y2_minus_y1k,
      B    => T2_SAVED,
      DIFF => t3_raw,
      COUT => c_dummy3
    );

  -- if k=0 => T3 = 0
  t3_gate : entity work.mux2_n
    generic map(N => N)
    port map(
      SEL => is_k0,
      D0  => t3_raw,
      D1  => ZERO_V,
      Y   => T3
    );

end architecture;
