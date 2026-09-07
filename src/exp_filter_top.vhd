library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp_filter_top is
  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    K   : in  unsigned(2 downto 0);
    X   : in  signed(31 downto 0);
    Y   : out signed(31 downto 0)
  );
end entity;

architecture structural of exp_filter_top is
  constant N : positive := 32;

  -- Registered I/O
  signal x_reg      : std_logic_vector(N-1 downto 0);
  signal k_reg      : std_logic_vector(2 downto 0);
  signal k_prev_reg : std_logic_vector(2 downto 0);  -- previous K
  signal y_reg      : std_logic_vector(N-1 downto 0);

  -- Filter states
  signal y1_reg : std_logic_vector(N-1 downto 0);
  signal y2_reg : std_logic_vector(N-1 downto 0);

  -- Saved values (used for term reuse)
  signal y1_shift_k_saved : std_logic_vector(N-1 downto 0);
  signal t2_saved         : std_logic_vector(N-1 downto 0);

  -- Terms
  signal t1_s, t2_s, t3_s : std_logic_vector(N-1 downto 0);

  -- Value to store for next cycle
  signal y1_shift_k_current : std_logic_vector(N-1 downto 0);

  -- Next output sample (combinational)
  signal y_next : std_logic_vector(N-1 downto 0);

  -- K change detection
  signal k_changed : std_logic;

begin

  -- --------------------------------------------------------
  -- Detect K changes (triggers state re-init in the state_register)
  cmp_k : entity work.comparator_n
    generic map (N => 3)
    port map (
      A   => k_reg,
      B   => k_prev_reg,
      NEQ => k_changed
    );

  -- --------------------------------------------------------------------
  -- Term generation
  tg : entity work.term_generator
    generic map (N => N)
    port map (
      K  => k_reg,
      X  => x_reg,
      Y1 => y1_reg,
      Y2 => y2_reg,

      Y1_SHIFT_K_SAVED => y1_shift_k_saved,
      T2_SAVED         => t2_saved,

      T1 => t1_s,
      T2 => t2_s,
      T3 => t3_s,

      Y1_SHIFT_K_OUT => y1_shift_k_current
    );

  -- ----------------------------------------------------------------
  -- Final sum: Y_next = T1 + T2 + T3
  dp : entity work.term_summer
    generic map (N => N)
    port map (
      T1     => t1_s,
      T2     => t2_s,
      T3     => t3_s,
      Y_NEXT => y_next
    );

  -- ------------------------------------------------------
  -- Registers (I/O, states, and saved terms)
  sr : entity work.state_register
    generic map (N => N)
    port map (
      CLK => CLK,
      RST => RST,
      EN  => '1',

      XIN => std_logic_vector(X),
      KIN => std_logic_vector(K),
      YIN => y_next,

      K_CHANGED => k_changed,

      XOUT      => x_reg,
      KOUT      => k_reg,
      KPREV_OUT => k_prev_reg,
      YOUT      => y_reg,

      Y1_SHIFT_K_IN  => y1_shift_k_current,
      T2_IN          => t2_s,

      Y1             => y1_reg,
      Y2             => y2_reg,
      Y1_SHIFT_K_OUT => y1_shift_k_saved,
      T2_OUT         => t2_saved
    );

  -- Output
  Y <= signed(y_reg);

end architecture;
