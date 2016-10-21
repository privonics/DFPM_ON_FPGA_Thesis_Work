----------------------------------------------------------------------------------
-- Company: 			Mid Sweden University
-- Engineer: 			Taiyelolu O. Adeboye (Student)
-- 
-- Create Date:    	14:56:46 02/06/2015 
-- Design Name: 		DFPM ON FPGA 
-- Module Name:    	DFPM_ON_FPGA_PROJECT_DEMO_TOP_MODULE - Behavioral 
-- Project Name: 		DFPM ON FPGA - An implementation of the Dynamic Functional Particle Method on Spartan 3E FPGA (Thesis work)
-- Target Devices: 	Xilinx's xc3s1200e-4fg320 - Spartan 3E on Nexys2 board
-- Tool versions: 	Xilinx ISE Project Navigator, Digilent's Adept (for programming) and other associated design, synthesis 
--							and verification tools
-- Description: 		This project is a thesis work, done in partial fulfilment of the requirements for the 
--							award of the degree of Bachelor in Electronics design in Mid Sweden University.
--							It is a design on Xilinx Spartan 3E FPGA using VHDL to implement the Dynamic Functional
--							Particle Method as invented by Prof. Sverker Edvardsson et al. 
--							
--							The complete and compiled design includes a UART module that facilitates the input of 
--							problem statements to be solved using the DFPM and the output of the solution 
--							in signed binary format. An accompanying MATLAB code is available for communicating
--							with the FPGA running this design.
--							
--							This thesis work was done under suprérvision of Asst. Prof. Kent Bertilsson and initial 
--							instructional guidance from Prof. Sverker.
--
-- Dependencies: 
--
-- Revision: 			I have lost count of the number of revisions. LOL. But let's say version 1.5 :-)
-- Revision 0.01 - File Created
-- Additional Comments: This specific file is an adaptation of Dan Pederson's design provided 
--								as a sample project for the UART on Nexys2
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_signed.all;
use IEEE.NUMERIC_STD.ALL;
use work.DFPM_ARRAY_5X32_BIT.all;	-- 5 by 1 of Signed signed vectors package
use work.DFPM_ARRAY_25X32_BIT.all;	

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DFPM_TO_UART is
	port(	CLK, RST : in STD_LOGIC;
			
			VECTOR_X_FROM_DFPM : in DFPM_SIGNED_VECTOR_5X32_BIT;
			ITERATIONS_COMPLETE : in STD_LOGIC;
			
			DATA_READY_FROM_DFPM : out STD_LOGIC;
			DATA_TO_UART_INTERFACE : out STD_LOGIC_VECTOR(7 downto 0);
			TBE_IN : in STD_LOGIC);
end DFPM_TO_UART;

architecture Behavioral of DFPM_TO_UART is
	
	
	type storage_type_dfpm is array (0 to 5) of std_logic_vector(40 downto 0);-- Larger so as to make room for the New line character
	
	
	Signal Sig_DFPM_storage_array : storage_type_dfpm := ("00000000000000000000000000000000000000000",
																			"00000000000000000000000000000000000000000",
																			"00000000000000000000000000000000000000000",
																			"00000000000000000000000000000000000000000",
																			"00000000000000000000000000000000000000000",
																			"00000000000000000000000000000000000000000");
	
		
	Signal Sig_UART_READ_Pos : integer := 0;
	
	Signal Sig_UART_READ_Pos_8BitPart : integer := 4;
	
	-----------------------------------------------------------------------------------
	Constant Const_Newline 	 			: std_logic_vector(7 downto 0) := "00001010";
	
	-----------------------------------------------------------------------------------
	
	
	begin
	
	process(clk)
		begin
			if rising_edge(clk) then
				DATA_READY_FROM_DFPM <= ITERATIONS_COMPLETE;
			end if;
		end process;
	
		
		------------------------------------------------------------------
	
	process(TBE_IN, Sig_UART_READ_Pos, Sig_UART_READ_Pos_8BitPart)
		Variable var_readPos, var_ReadPos_8bitPart : integer := 0;
		begin
			if rising_edge(TBE_IN) then
				if (Sig_UART_READ_Pos < 5) then
					
					--Bits 31 downto 24, 	then 23 downto 16, then 15 downto 8, then 7 downto 0
					--in successive bit transmissions through the UART is equivalent to ->
					--(8(x + 1) - 1) downto (8*x) where x is the Sig_UART_READ_Pos_8BitPart
					-- This approach will transmit the data contained in each element of the solution vector
					-- in series if 8 bits starting from the MSB to the LSB
					--------------------------------------
					if (Sig_UART_READ_Pos_8BitPart = 4) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(39 downto 32);
					elsif (Sig_UART_READ_Pos_8BitPart = 3) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(31 downto 24);
					elsif (Sig_UART_READ_Pos_8BitPart = 2) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(23 downto 16);
					elsif (Sig_UART_READ_Pos_8BitPart = 1) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(15 downto 8);
					elsif (Sig_UART_READ_Pos_8BitPart = 0) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(7 downto 0);
					end if;
					
																				
					if (Sig_UART_READ_Pos_8BitPart = 0) then
						Sig_UART_READ_Pos_8BitPart <= 4;
						
						var_readPos := Sig_UART_READ_Pos;
						Sig_UART_READ_Pos <= var_readPos + 1;
					else
						var_ReadPos_8bitPart := Sig_UART_READ_Pos_8BitPart;
						Sig_UART_READ_Pos_8BitPart <= var_ReadPos_8bitPart - 1;
					end if;
				end if;
			end if;
		end process;
	------------------------------------------------------------------
	
		-------------------------------------------------------------------------------------
	
	process(clk, ITERATIONS_COMPLETE)
		begin
			if rising_edge(clk) then
				if (ITERATIONS_COMPLETE = '1') then
					-- Direct assignment of the output of the DFPM module to the output storage
					Sig_DFPM_storage_array(0) <= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(1) <= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(2) <= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(3) <= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(4) <= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;
				end if;
			end if;
		end process;
	
	------------------------------------------------------------------
		
		
	end Behavioral;

