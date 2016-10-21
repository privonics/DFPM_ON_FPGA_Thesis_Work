# DFPM_ON_FPGA_Thesis_Work
Thesis work for my Bachelor degree

This repository contains HDL (and sokme C++) codes used in my Bachelor thesis work. 

The thesis was centered around an implementation of the Dynamic Functional Particle Method (DFPM) in digital electronics.

For the design, I made use of VHDL and made a design for the Xilinx Spartan 3E FPGA (Field Programmable Gates Array) sing Xilinx ISE as the primary development environment.

The completed HDL design was programmed into a chip on the Nexys2 board for testing.

When programmed, the chip waits to be recieve an ODE problem stated in equation form and returns the solution after having solved it with DFPM implemented internally in its circuitry. The data exchange can be done through any computational device (MCU, SBC up to full fledged PCs) capable of UART communication.

In this thesis work, the data exchange was done with the aid of MATLAB and, optionally, a simple terminal running on a windows PC.

The HDL design includes:
- DFPM implementation modules
- UART implementation modules
- Data conversion modules etc.
