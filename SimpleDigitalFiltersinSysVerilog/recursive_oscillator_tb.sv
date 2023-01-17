`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD 10
`define FULL_CLOCK_PERIOD 20
`define RESET_PERIOD      40
`define TEST_PERIOD       400
`define SIM_DURATION      50000000


module recursive_oscillator_tb();

logic tb_clk = 1'b0;
logic tb_reset_n = 1'b0;
logic signed [15:0] tb_d;
logic signed [15:0] tb_q_sin, tb_q_cos;
logic signed [31:0] tb_q_prod_1, tb_q_prod_2;

//clock generation
	initial
		begin:clock_generation
			tb_clk = 1'b0;
			forever
				begin
					#`HALF_CLOCK_PERIOD tb_clk = ~tb_clk;
				end
		end:clock_generation
		
//testbench scheduler
	
	initial
		begin:testbench_scheduler
			
			//ascii_string = "unit response";			
			//d_tb = 16'sb0000000000000000;
			//#`FULL_CLOCK_PERIOD
			tb_reset_n = 1'b0;
			#`FULL_CLOCK_PERIOD
			tb_reset_n = 1'b1;
			//#`FULL_CLOCK_PERIOD
			//d_tb = 16'sb0010000000000000;
			//#`FULL_CLOCK_PERIOD
			//d_tb = 16'sb0000000000000000;
			#`SIM_DURATION
			$stop();
		end:testbench_scheduler

//module instance
	recursive_oscillator inst_dut(.clk(tb_clk),
											.reset_n(tb_reset_n),
											//.d(d_tb),
											.q_sin(tb_q_sin),
											.q_cos(tb_q_cos),
											.q_prod_1(tb_q_prod_1),
											.q_prod_2(tb_q_prod_2)
										  );
							
endmodule 
