`timescale 1ns/1ps
`define FULL_CLOCK_PERIOD 	20
`define HALF_CLOCK_PERIOD	10
`define RESET_PERIOD			1500
`define SIM_DURATION			2000000000

module digital_resonator_tb();

	logic tb_local_clock = 0;
	initial
	begin: clock_generation_process
		tb_local_clock = 0;
			forever begin
				#`HALF_CLOCK_PERIOD tb_local_clock = ~tb_local_clock;
			end
	end
	
	localparam SYSTEM_FREQUENCY   = 50000000;
	localparam SAMPLING_FREQUENCY = 5000;
	localparam CLOCK_TICKS        = SYSTEM_FREQUENCY/SAMPLING_FREQUENCY;
	localparam BIT_WIDTH          = $clog2(CLOCK_TICKS);	 

	logic [BIT_WIDTH:0] time_base_counter = 0;

	logic tb_local_reset_n = 1'b1;
	
	always_ff@(posedge tb_local_clock)
		if(tb_local_reset_n == 1'b0)
			time_base_counter <= 0;
		else
			time_base_counter <= (time_base_counter + 1'b1) % CLOCK_TICKS;
			
	logic enable; assign enable = (time_base_counter == (CLOCK_TICKS - 1'b1)) ? 1'b1 : 1'b0;	

	logic signed [15:0] tb_test_sig = 16'sb0000000000000000;	 
	logic signed [15:0] tb_q;				

	initial
	begin
		$readmemh("resonator_test_signal.txt", test_signal_rom);
	end
	
	logic signed [15:0] test_signal_rom [2**12-1:0];
	
	logic [15:0] lut_address = 1'd0;										 
	
	initial
		begin: reset_generation_process
			$display ("Simulation starts ...");
			reset_filter;
			#`SIM_DURATION
			$display ("Simulation done ...");
			$stop();
		end
		
		always_ff@(posedge enable)
			if(tb_local_reset_n == 1'b0)
				tb_test_sig = 0;
			else
				tb_test_sig = (test_signal_rom[lut_address]);
					
		always_ff@(posedge enable)
			if(tb_local_reset_n == 1'b0)
				lut_address = 0;
			else
				lut_address = (lut_address + 1);
		
		digital_resonator resonator_inst(.clk(tb_local_clock),
													.reset_n(tb_local_reset_n),
													.enable(enable),
													.d(tb_test_sig),
													.q(tb_q)
													);
										  		  				  
		task reset_filter; 
			begin
				tb_local_reset_n = 1'b0;
				#`RESET_PERIOD
				tb_local_reset_n = 1'b1;
			end
		endtask
		
endmodule
