
`timescale 1ns/1ps

`define HALF_CLOCK_PERIOD     10
`define RESET_PERIOD 	      20
`define SIM_DURATION 	50000000

module exponential_averager_filter_tb();
	
	logic tb_local_clock = 0;
	logic tb_local_reset = 1'b0;
	logic signed [15:0] tb_filter_input;
	logic signed [15:0] tb_filter_output;
	
	// ### clock generation process ..
	
	
	initial 
		begin: clock_generation_process
			tb_local_clock = 0;
			forever	
				begin
					#`HALF_CLOCK_PERIOD tb_local_clock = ~tb_local_clock;
				end
		end	
		
	// ### (active low) reset generation process ...
	
	initial 
		begin: reset_generation_process
			$display ("Simulation starts ...");
			#`RESET_PERIOD tb_local_reset = 1'b1;	
			#`SIM_DURATION
			$stop();
		end
		
	exponential_averager_filter inst_0(.clk(tb_local_clock),
												  .reset_n(tb_local_reset),
												  .q_sine(tb_filter_input),
												  .q(tb_filter_output)
												);		
endmodule
