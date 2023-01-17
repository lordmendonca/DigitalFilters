
module exponential_averager_filter(
	input logic clk, input logic reset_n,
	output logic signed [15:0] q_sine,
	output logic signed [15:0] q
	);
		
	localparam SYSTEM_FREQUENCY   = 50000000;
	localparam SAMPLING_FREQUENCY = 48000;
	localparam CLOCK_TICKS        = SYSTEM_FREQUENCY/SAMPLING_FREQUENCY;
		
	// ### time base generation - 48kHz sampling frequency ...	
	logic enable;
	
	localparam BIT_WIDTH = $clog2(CLOCK_TICKS);	 
		
	logic [BIT_WIDTH : 0] time_base_counter = 0;
	
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			time_base_counter <= 0;
		else
			time_base_counter <= (time_base_counter + 1'b1) % CLOCK_TICKS;
			
	assign enable = (time_base_counter == (CLOCK_TICKS - 1'b1)) ? 1'b1 : 1'b0;	
	
	// ### a simple ROM provides the test signal, which has been generated using MATLAB
		
	logic [7:0] rom_address = 0;
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			rom_address <= 8'd0;
		else
			if(enable)
				rom_address <= rom_address + 1'b1;
	
	// here, we simply implement the ROM right here ... 
	
	logic signed [15:0] rom_memory [2**8-1:0];

	// the text file used to initialise the rom_memory variable needs to be present 
	// in the project directory for synthesis as well as in the subdirectory simulation/modelsi
	// for simulation purposes ... So copy it to the respective locations! 
	
	initial
		$readmemh("noisy_sine_0_360_16bit_256.txt", rom_memory);
		
	logic signed [15:0] q_rom = 0;
	
	always_ff@(posedge clk)
		q_rom <= $signed(rom_memory[rom_address]);	
		
	assign q_sine = q_rom;
		
	// ### exponential averager low-pass filter

	localparam signed [15:0] ff_coefficient = 16'sb0000110011001100; // 0.1
	localparam signed [15:0] fb_coefficient = 16'sb0111001100110011; // 0.9

	logic signed [31:0] product_0, product_1;
	logic signed [15:0] q_delayed;
	
	assign product_0 = q_rom * ff_coefficient;
	assign product_1 = q_delayed * fb_coefficient;
	assign q 		  = $signed(product_0[30:15]) + $signed(product_1[30:15]);
				
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
		   q_delayed <= 16'd0;
		else
		   if(enable) 	q_delayed <= q;
				
endmodule 

/*

clear all;
close all;
clc;

t = linspace(0,1,257);             
f = fi(  ( 0.5*sin(2*pi*1*(t)) + 0.4*sin(2*pi*117*(t)) )  ,1,16,15);

set(gcf,'color','w');
plot(t,f);
box off; axis tight;

fileID1 = fopen('C:\intelFPGA_lite\18.1\projects\de10_standard\simulation\modelsim\noisy_sine_0_360_16bit_256.txt','w');
fileID2 = fopen('C:\intelFPGA_lite\18.1\projects\de10_standard\sph_lecture_demos\exponential_averager_filter\noisy_sine_0_360_16bit_256.txt','w');

for i=1:length(f)-1
    fprintf(fileID1,'%s\n',hex(f(i)));
    fprintf(fileID2,'%s\n',hex(f(i)));
end

fclose(fileID1);
fclose(fileID2);
*/


