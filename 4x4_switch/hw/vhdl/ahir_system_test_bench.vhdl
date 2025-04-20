library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library aHiR_ieee_proposed;
use aHiR_ieee_proposed.math_utility_pkg.all;
use aHiR_ieee_proposed.fixed_pkg.all;
use aHiR_ieee_proposed.float_pkg.all;
library ahir;
use ahir.memory_subsystem_package.all;
use ahir.types.all;
use ahir.subprograms.all;
use ahir.components.all;
use ahir.basecomponents.all;
use ahir.operatorpackage.all;
use ahir.floatoperatorpackage.all;
use ahir.utilities.all;
library work;
use work.ahir_system_global_package.all;
library GhdlLink;
use GhdlLink.Utility_Package.all;
use GhdlLink.Vhpi_Foreign.all;
entity ahir_system_Test_Bench is -- 
  -- 
end entity;
architecture VhpiLink of ahir_system_Test_Bench is -- 
  component ahir_system is -- 
    port (-- 
      initialiseCounters_tag_in: in std_logic_vector(1 downto 0);
      initialiseCounters_tag_out: out std_logic_vector(1 downto 0);
      initialiseCounters_start_req : in std_logic;
      initialiseCounters_start_ack : out std_logic;
      initialiseCounters_fin_req   : in std_logic;
      initialiseCounters_fin_ack   : out std_logic;
      clk : in std_logic;
      reset : in std_logic;
      in_data_1_pipe_write_data: in std_logic_vector(31 downto 0);
      in_data_1_pipe_write_req : in std_logic_vector(0 downto 0);
      in_data_1_pipe_write_ack : out std_logic_vector(0 downto 0);
      in_data_2_pipe_write_data: in std_logic_vector(31 downto 0);
      in_data_2_pipe_write_req : in std_logic_vector(0 downto 0);
      in_data_2_pipe_write_ack : out std_logic_vector(0 downto 0);
      in_data_3_pipe_write_data: in std_logic_vector(31 downto 0);
      in_data_3_pipe_write_req : in std_logic_vector(0 downto 0);
      in_data_3_pipe_write_ack : out std_logic_vector(0 downto 0);
      in_data_4_pipe_write_data: in std_logic_vector(31 downto 0);
      in_data_4_pipe_write_req : in std_logic_vector(0 downto 0);
      in_data_4_pipe_write_ack : out std_logic_vector(0 downto 0);
      out_data_1_pipe_read_data: out std_logic_vector(31 downto 0);
      out_data_1_pipe_read_req : in std_logic_vector(0 downto 0);
      out_data_1_pipe_read_ack : out std_logic_vector(0 downto 0);
      out_data_2_pipe_read_data: out std_logic_vector(31 downto 0);
      out_data_2_pipe_read_req : in std_logic_vector(0 downto 0);
      out_data_2_pipe_read_ack : out std_logic_vector(0 downto 0);
      out_data_3_pipe_read_data: out std_logic_vector(31 downto 0);
      out_data_3_pipe_read_req : in std_logic_vector(0 downto 0);
      out_data_3_pipe_read_ack : out std_logic_vector(0 downto 0);
      out_data_4_pipe_read_data: out std_logic_vector(31 downto 0);
      out_data_4_pipe_read_req : in std_logic_vector(0 downto 0);
      out_data_4_pipe_read_ack : out std_logic_vector(0 downto 0)); -- 
    -- 
  end component;
  signal clk: std_logic := '0';
  signal reset: std_logic := '1';
  signal initialiseCounters_tag_in: std_logic_vector(1 downto 0);
  signal initialiseCounters_tag_out: std_logic_vector(1 downto 0);
  signal initialiseCounters_start_req : std_logic := '0';
  signal initialiseCounters_start_ack : std_logic := '0';
  signal initialiseCounters_fin_req   : std_logic := '0';
  signal initialiseCounters_fin_ack   : std_logic := '0';
  signal inputPort_1_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal inputPort_1_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal inputPort_1_Daemon_start_req : std_logic := '0';
  signal inputPort_1_Daemon_start_ack : std_logic := '0';
  signal inputPort_1_Daemon_fin_req   : std_logic := '0';
  signal inputPort_1_Daemon_fin_ack   : std_logic := '0';
  signal inputPort_2_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal inputPort_2_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal inputPort_2_Daemon_start_req : std_logic := '0';
  signal inputPort_2_Daemon_start_ack : std_logic := '0';
  signal inputPort_2_Daemon_fin_req   : std_logic := '0';
  signal inputPort_2_Daemon_fin_ack   : std_logic := '0';
  signal inputPort_3_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal inputPort_3_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal inputPort_3_Daemon_start_req : std_logic := '0';
  signal inputPort_3_Daemon_start_ack : std_logic := '0';
  signal inputPort_3_Daemon_fin_req   : std_logic := '0';
  signal inputPort_3_Daemon_fin_ack   : std_logic := '0';
  signal inputPort_4_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal inputPort_4_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal inputPort_4_Daemon_start_req : std_logic := '0';
  signal inputPort_4_Daemon_start_ack : std_logic := '0';
  signal inputPort_4_Daemon_fin_req   : std_logic := '0';
  signal inputPort_4_Daemon_fin_ack   : std_logic := '0';
  signal outputPort_1_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal outputPort_1_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal outputPort_1_Daemon_start_req : std_logic := '0';
  signal outputPort_1_Daemon_start_ack : std_logic := '0';
  signal outputPort_1_Daemon_fin_req   : std_logic := '0';
  signal outputPort_1_Daemon_fin_ack   : std_logic := '0';
  signal outputPort_2_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal outputPort_2_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal outputPort_2_Daemon_start_req : std_logic := '0';
  signal outputPort_2_Daemon_start_ack : std_logic := '0';
  signal outputPort_2_Daemon_fin_req   : std_logic := '0';
  signal outputPort_2_Daemon_fin_ack   : std_logic := '0';
  signal outputPort_3_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal outputPort_3_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal outputPort_3_Daemon_start_req : std_logic := '0';
  signal outputPort_3_Daemon_start_ack : std_logic := '0';
  signal outputPort_3_Daemon_fin_req   : std_logic := '0';
  signal outputPort_3_Daemon_fin_ack   : std_logic := '0';
  signal outputPort_4_Daemon_tag_in: std_logic_vector(1 downto 0);
  signal outputPort_4_Daemon_tag_out: std_logic_vector(1 downto 0);
  signal outputPort_4_Daemon_start_req : std_logic := '0';
  signal outputPort_4_Daemon_start_ack : std_logic := '0';
  signal outputPort_4_Daemon_fin_req   : std_logic := '0';
  signal outputPort_4_Daemon_fin_ack   : std_logic := '0';
  -- write to pipe in_data_1
  signal in_data_1_pipe_write_data: std_logic_vector(31 downto 0);
  signal in_data_1_pipe_write_req : std_logic_vector(0 downto 0) := (others => '0');
  signal in_data_1_pipe_write_ack : std_logic_vector(0 downto 0);
  -- write to pipe in_data_2
  signal in_data_2_pipe_write_data: std_logic_vector(31 downto 0);
  signal in_data_2_pipe_write_req : std_logic_vector(0 downto 0) := (others => '0');
  signal in_data_2_pipe_write_ack : std_logic_vector(0 downto 0);
  -- write to pipe in_data_3
  signal in_data_3_pipe_write_data: std_logic_vector(31 downto 0);
  signal in_data_3_pipe_write_req : std_logic_vector(0 downto 0) := (others => '0');
  signal in_data_3_pipe_write_ack : std_logic_vector(0 downto 0);
  -- write to pipe in_data_4
  signal in_data_4_pipe_write_data: std_logic_vector(31 downto 0);
  signal in_data_4_pipe_write_req : std_logic_vector(0 downto 0) := (others => '0');
  signal in_data_4_pipe_write_ack : std_logic_vector(0 downto 0);
  -- read from pipe out_data_1
  signal out_data_1_pipe_read_data: std_logic_vector(31 downto 0);
  signal out_data_1_pipe_read_req : std_logic_vector(0 downto 0) := (others => '0');
  signal out_data_1_pipe_read_ack : std_logic_vector(0 downto 0);
  -- read from pipe out_data_2
  signal out_data_2_pipe_read_data: std_logic_vector(31 downto 0);
  signal out_data_2_pipe_read_req : std_logic_vector(0 downto 0) := (others => '0');
  signal out_data_2_pipe_read_ack : std_logic_vector(0 downto 0);
  -- read from pipe out_data_3
  signal out_data_3_pipe_read_data: std_logic_vector(31 downto 0);
  signal out_data_3_pipe_read_req : std_logic_vector(0 downto 0) := (others => '0');
  signal out_data_3_pipe_read_ack : std_logic_vector(0 downto 0);
  -- read from pipe out_data_4
  signal out_data_4_pipe_read_data: std_logic_vector(31 downto 0);
  signal out_data_4_pipe_read_req : std_logic_vector(0 downto 0) := (others => '0');
  signal out_data_4_pipe_read_ack : std_logic_vector(0 downto 0);
  -- 
begin --
  -- clock/reset generation 
  clk <= not clk after 5 ns;
  -- assert reset for four clocks.
  process
  begin --
    Vhpi_Initialize;
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    reset <= '0';
    while true loop --
      wait until clk = '0';
      Vhpi_Listen;
      Vhpi_Send;
      --
    end loop;
    wait;
    --
  end process;
  -- connect all the top-level modules to Vhpi
  process
  variable val_string, obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns;
      obj_ref := Pack_String_To_VHPI_String("initialiseCounters req");
      Vhpi_Get_Port_Value(obj_ref,val_string,1);
      initialiseCounters_start_req <= To_Std_Logic(val_string);
      wait for 0 ns;
      if initialiseCounters_start_req = '1' then -- 
        while true loop --
          wait until clk = '1';
          if initialiseCounters_start_ack = '1' then exit; end if;--
        end loop; 
        initialiseCounters_start_req <= '0';
        initialiseCounters_fin_req <= '1';
        while true loop -- 
          wait until clk = '1';
          if initialiseCounters_fin_ack = '1' then exit; end if; --  
        end loop; 
        initialiseCounters_fin_req <= '0';
        -- 
      end if; 
      obj_ref := Pack_String_To_Vhpi_String("initialiseCounters ack");
      val_string := To_String(initialiseCounters_fin_ack);
      Vhpi_Set_Port_Value(obj_ref,val_string,1);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("in_data_1 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      in_data_1_pipe_write_req <= Unpack_String(req_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("in_data_1 0");
      Vhpi_Get_Port_Value(obj_ref,port_val_string,32);
      in_data_1_pipe_write_data <= Unpack_String(port_val_string,32);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("in_data_1 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(in_data_1_pipe_write_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("in_data_2 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      in_data_2_pipe_write_req <= Unpack_String(req_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("in_data_2 0");
      Vhpi_Get_Port_Value(obj_ref,port_val_string,32);
      in_data_2_pipe_write_data <= Unpack_String(port_val_string,32);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("in_data_2 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(in_data_2_pipe_write_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("in_data_3 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      in_data_3_pipe_write_req <= Unpack_String(req_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("in_data_3 0");
      Vhpi_Get_Port_Value(obj_ref,port_val_string,32);
      in_data_3_pipe_write_data <= Unpack_String(port_val_string,32);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("in_data_3 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(in_data_3_pipe_write_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("in_data_4 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      in_data_4_pipe_write_req <= Unpack_String(req_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("in_data_4 0");
      Vhpi_Get_Port_Value(obj_ref,port_val_string,32);
      in_data_4_pipe_write_data <= Unpack_String(port_val_string,32);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("in_data_4 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(in_data_4_pipe_write_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("out_data_1 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      out_data_1_pipe_read_req <= Unpack_String(req_val_string,1);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("out_data_1 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(out_data_1_pipe_read_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("out_data_1 0");
      port_val_string := Pack_SLV_To_Vhpi_String(out_data_1_pipe_read_data);
      Vhpi_Set_Port_Value(obj_ref,port_val_string,32);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("out_data_2 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      out_data_2_pipe_read_req <= Unpack_String(req_val_string,1);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("out_data_2 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(out_data_2_pipe_read_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("out_data_2 0");
      port_val_string := Pack_SLV_To_Vhpi_String(out_data_2_pipe_read_data);
      Vhpi_Set_Port_Value(obj_ref,port_val_string,32);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("out_data_3 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      out_data_3_pipe_read_req <= Unpack_String(req_val_string,1);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("out_data_3 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(out_data_3_pipe_read_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("out_data_3 0");
      port_val_string := Pack_SLV_To_Vhpi_String(out_data_3_pipe_read_data);
      Vhpi_Set_Port_Value(obj_ref,port_val_string,32);
      -- 
    end loop;
    --
  end process;
  process
  variable port_val_string, req_val_string, ack_val_string,  obj_ref: VhpiString;
  begin --
    wait until reset = '0';
    -- let the DUT come out of reset.... give it 4 cycles.
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    wait until clk = '1';
    while true loop -- 
      wait until clk = '0';
      wait for 1 ns; 
      obj_ref := Pack_String_To_Vhpi_String("out_data_4 req");
      Vhpi_Get_Port_Value(obj_ref,req_val_string,1);
      out_data_4_pipe_read_req <= Unpack_String(req_val_string,1);
      wait until clk = '1';
      obj_ref := Pack_String_To_Vhpi_String("out_data_4 ack");
      ack_val_string := Pack_SLV_To_Vhpi_String(out_data_4_pipe_read_ack);
      Vhpi_Set_Port_Value(obj_ref,ack_val_string,1);
      obj_ref := Pack_String_To_Vhpi_String("out_data_4 0");
      port_val_string := Pack_SLV_To_Vhpi_String(out_data_4_pipe_read_data);
      Vhpi_Set_Port_Value(obj_ref,port_val_string,32);
      -- 
    end loop;
    --
  end process;
  ahir_system_instance: ahir_system -- 
    port map ( -- 
      initialiseCounters_tag_in => initialiseCounters_tag_in,
      initialiseCounters_tag_out => initialiseCounters_tag_out,
      initialiseCounters_start_req => initialiseCounters_start_req,
      initialiseCounters_start_ack => initialiseCounters_start_ack,
      initialiseCounters_fin_req  => initialiseCounters_fin_req, 
      initialiseCounters_fin_ack  => initialiseCounters_fin_ack ,
      clk => clk,
      reset => reset,
      in_data_1_pipe_write_data  => in_data_1_pipe_write_data, 
      in_data_1_pipe_write_req  => in_data_1_pipe_write_req, 
      in_data_1_pipe_write_ack  => in_data_1_pipe_write_ack,
      in_data_2_pipe_write_data  => in_data_2_pipe_write_data, 
      in_data_2_pipe_write_req  => in_data_2_pipe_write_req, 
      in_data_2_pipe_write_ack  => in_data_2_pipe_write_ack,
      in_data_3_pipe_write_data  => in_data_3_pipe_write_data, 
      in_data_3_pipe_write_req  => in_data_3_pipe_write_req, 
      in_data_3_pipe_write_ack  => in_data_3_pipe_write_ack,
      in_data_4_pipe_write_data  => in_data_4_pipe_write_data, 
      in_data_4_pipe_write_req  => in_data_4_pipe_write_req, 
      in_data_4_pipe_write_ack  => in_data_4_pipe_write_ack,
      out_data_1_pipe_read_data  => out_data_1_pipe_read_data, 
      out_data_1_pipe_read_req  => out_data_1_pipe_read_req, 
      out_data_1_pipe_read_ack  => out_data_1_pipe_read_ack ,
      out_data_2_pipe_read_data  => out_data_2_pipe_read_data, 
      out_data_2_pipe_read_req  => out_data_2_pipe_read_req, 
      out_data_2_pipe_read_ack  => out_data_2_pipe_read_ack ,
      out_data_3_pipe_read_data  => out_data_3_pipe_read_data, 
      out_data_3_pipe_read_req  => out_data_3_pipe_read_req, 
      out_data_3_pipe_read_ack  => out_data_3_pipe_read_ack ,
      out_data_4_pipe_read_data  => out_data_4_pipe_read_data, 
      out_data_4_pipe_read_req  => out_data_4_pipe_read_req, 
      out_data_4_pipe_read_ack  => out_data_4_pipe_read_ack ); -- 
  -- 
end VhpiLink;
