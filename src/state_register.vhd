library ieee;
use ieee.std_logic_1164.all;

entity state_register is
  generic ( N : positive := 32 );
  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    EN  : in  std_logic;

    XIN : in  std_logic_vector(N-1 downto 0);
    KIN : in  std_logic_vector(2 downto 0);
    YIN : in  std_logic_vector(N-1 downto 0);

    K_CHANGED : in std_logic;

    XOUT      : out std_logic_vector(N-1 downto 0);
    KOUT      : out std_logic_vector(2 downto 0);
    KPREV_OUT : out std_logic_vector(2 downto 0);
    YOUT      : out std_logic_vector(N-1 downto 0);  -- = Y1

    Y1_SHIFT_K_IN  : in  std_logic_vector(N-1 downto 0);
    T2_IN          : in  std_logic_vector(N-1 downto 0);

    Y1             : out std_logic_vector(N-1 downto 0);
    Y2             : out std_logic_vector(N-1 downto 0);
    Y1_SHIFT_K_OUT : out std_logic_vector(N-1 downto 0);
    T2_OUT         : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture structural of state_register is
  signal x_q      : std_logic_vector(N-1 downto 0);
  signal k_q      : std_logic_vector(2 downto 0);
  signal k_prev_q : std_logic_vector(2 downto 0);

  signal y1_q        : std_logic_vector(N-1 downto 0);
  signal y2_q        : std_logic_vector(N-1 downto 0);
  signal y1_shift_k_q: std_logic_vector(N-1 downto 0);
  signal t2_q        : std_logic_vector(N-1 downto 0);

  signal rst_states : std_logic;
begin

  rst_states <= RST or K_CHANGED;

  -- Input registers
  reg_x : entity work.register_n
    generic map (N => N)
    port map (CLK => CLK, RST => RST, EN => EN, D => XIN, Q => x_q);

  reg_k : entity work.register_n
    generic map (N => 3)
    port map (CLK => CLK, RST => RST, EN => EN, D => KIN, Q => k_q);

  -- Previous K (registered)
  reg_k_prev : entity work.register_n
    generic map (N => 3)
    port map (CLK => CLK, RST => RST, EN => EN, D => k_q, Q => k_prev_q);

  -- State registers (NO extra reg_y)
  reg_y1 : entity work.register_n
    generic map (N => N)
    port map (CLK => CLK, RST => rst_states, EN => EN, D => YIN, Q => y1_q);

  reg_y2 : entity work.register_n
    generic map (N => N)
    port map (CLK => CLK, RST => rst_states, EN => EN, D => y1_q, Q => y2_q);

  reg_y1_shift_k : entity work.register_n
    generic map (N => N)
    port map (CLK => CLK, RST => rst_states, EN => EN, D => Y1_SHIFT_K_IN, Q => y1_shift_k_q);

  reg_t2 : entity work.register_n
    generic map (N => N)
    port map (CLK => CLK, RST => rst_states, EN => EN, D => T2_IN, Q => t2_q);

  -- Outputs
  XOUT      <= x_q;
  KOUT      <= k_q;
  KPREV_OUT <= k_prev_q;

  YOUT <= y1_q; 
  Y1   <= y1_q;
  Y2   <= y2_q;

  Y1_SHIFT_K_OUT <= y1_shift_k_q;
  T2_OUT         <= t2_q;

end architecture;
