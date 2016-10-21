----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:15:34 07/18/2015 
-- Design Name: 
-- Module Name:    TEST_CONVERSIONS_THROUGH_UART - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_signed.all;
use IEEE.NUMERIC_STD.ALL;

use work.DFPM_VECTOR_5X32_BIT.all;	-- 5 by 1 matrix of std logic vectors package
use work.DFPM_VECTOR_25X32_BIT.all; -- 5 by 5 matrix of std_logic_vectors package
use work.DFPM_ARRAY_5X32_BIT.all;	-- 5 by 1 of Signed signed vectors package
use work.DFPM_ARRAY_25X32_BIT.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TEST_CONVERSIONS_THROUGH_UART is
	port(	DATA_IN_1: in std_logic_vectors(7 downto 0);
			DATA_IN_1: in std_logic_vectors(7 downto 0);
			DATA_IN_1: in std_logic_vectors(7 downto 0);
			DATA_IN_1: in std_logic_vectors(7 downto 0);
			DATA_IN_1: in std_logic_signed(7 downto 0);
			DATA_OUT : out std_logic_vectors(7 downto 0));
end TEST_CONVERSIONS_THROUGH_UART;

architecture Behavioral of TEST_CONVERSIONS_THROUGH_UART is

begin


end Behavioral;

