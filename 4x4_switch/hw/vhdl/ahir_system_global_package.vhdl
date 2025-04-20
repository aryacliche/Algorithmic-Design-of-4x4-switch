-- VHDL global package produced by vc2vhdl from virtual circuit (vc) description 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ahir_system_global_package is -- 
  constant ONE_1 : std_logic_vector(0 downto 0) := "1";
  constant ONE_2 : std_logic_vector(1 downto 0) := "01";
  constant ONE_33 : std_logic_vector(32 downto 0) := "000000000000000000000000000000001";
  constant ONE_8 : std_logic_vector(7 downto 0) := "00000001";
  constant ZERO_1 : std_logic_vector(0 downto 0) := "0";
  constant ZERO_16 : std_logic_vector(15 downto 0) := "0000000000000000";
  constant ZERO_2 : std_logic_vector(1 downto 0) := "00";
  constant ZERO_3 : std_logic_vector(2 downto 0) := "000";
  constant ZERO_33 : std_logic_vector(32 downto 0) := "000000000000000000000000000000000";
  constant ZERO_8 : std_logic_vector(7 downto 0) := "00000000";
  constant obuf_semaphore_base_address : std_logic_vector(3 downto 0) := "0000";
  -- 
end package ahir_system_global_package;
