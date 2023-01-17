module recursive_oscillator
(
	input logic clk,
	input logic reset_n,
	//input logic signed [15:0] d,
	output logic signed [15:0] q_sin,
	output logic signed [15:0] q_cos,
	output logic signed [31:0] q_prod_1,
	output logic signed [31:0] q_prod_2
);
	
	
	localparam SYSTEM_FREQUENCY = 50000000;
	localparam SAMPLING_FREQUENCY = 100000;
	localparam OUTPUT_FREQUENCY = 1000;
	localparam CLOCK_TICKS = SYSTEM_FREQUENCY/SAMPLING_FREQUENCY;
	
	
	localparam BITWIDTH = $clog2(CLOCK_TICKS + 1);
	
	logic [BITWIDTH-1:0] time_base_counter = 0;
	
	logic enable;
	
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			time_base_counter <= 0;
		else
			time_base_counter <= (time_base_counter + 1'b1) % CLOCK_TICKS;
			
	assign enable = (time_base_counter == (CLOCK_TICKS - 1'b1))? 1'b1 : 1'b0;
	
	logic signed [15:0] x_n;
	logic signed [15:0] w_n;
	logic signed [15:0] w_n_1;
	logic signed [15:0] w_n_2;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
	begin
		x_n 	<= 16'sb0010000000000000;
		w_n_1 <= 16'sb0000000000000000;
		w_n_2 <= 16'sb0000000000000000;
	end
	else if(enable)
	begin
		x_n 	<= 16'sb0000000000000000;
		w_n_1 <= w_n;
		w_n_2 <= w_n_1;
	end
	
	localparam signed [15:0] a1 = 16'sb0010000000000000;
	localparam signed [15:0] a2 = 16'sb0011111111100000;
	localparam signed [15:0] a3 = 16'sb1110000000000000;
	localparam signed [15:0] a4 = 16'sb0000001000000010;
	localparam signed [15:0] a5 = 16'sb0010000000000000;
	localparam signed [15:0] a6 = 16'sb1110000000010000;
	
	logic signed [31:0] a2_w_n_1;	assign a2_w_n_1 = a2 * w_n_1;
	logic signed [31:0] a3_w_n_2;	assign a3_w_n_2 = a3 * w_n_2;
	logic signed [31:0] a4_w_n_1; assign a4_w_n_1 = a4 * w_n_1;
	logic signed [31:0] a5_w_n;	assign a5_w_n = a5 * w_n;
	logic signed [31:0] a6_w_n_1;	assign a6_w_n_1 = a6 * w_n_1;
	
	logic signed [15:0] temp_a2_w_n_1; assign temp_a2_w_n_1 = $signed(a2_w_n_1[30:15]);
	logic signed [15:0] temp_a3_w_n_2; assign temp_a3_w_n_2 = $signed(a3_w_n_2[30:15]);
	logic signed [15:0] temp_a4_w_n_1; assign temp_a4_w_n_1 = $signed(a4_w_n_1[30:15]);
	logic signed [15:0] temp_a5_w_n; assign temp_a5_w_n = $signed(a5_w_n[30:15]);
	logic signed [15:0] temp_a6_w_n_1; assign temp_a6_w_n_1 = $signed(a6_w_n_1[30:15]);
	
	assign w_n = (x_n + temp_a2_w_n_1 + temp_a3_w_n_2) <<< 4;
	assign q_sin = (temp_a4_w_n_1) <<< 4;
	assign q_cos = (temp_a5_w_n + temp_a6_w_n_1) <<< 4;
	

//	//Q4.12
////	localparam signed [15:0] cosw0 	= 16'sb0111111110111111; //0.998028728
////	localparam signed [15:0] sinw0	= 16'sb0000100000001000; //0.06275872928
//
//	localparam signed [15:0] cosw0 	= 16'sb0000111111111000; //0.998028728
//	localparam signed [15:0] sinw0	= 16'sb0000000100000001; //0.06275872928
//	
//	logic signed [31:0] prod_1, prod_2, prod_3;
//	
////	assign prod_1 = cosw0 * w_n_1;
////	assign prod_2 = $signed(prod_1) << 1; // multiply by 2?
////	assign w_n = $signed(x_n) + $signed(prod_2[31:16]) - $signed(w_n_2);
////	assign prod_3 = sinw0 * w_n_1;
//
//	assign prod_1 = cosw0 * w_n_1;
//	assign prod_2 = $signed({prod_1[31:30], prod_1[29:0] << 1}); // multiply by 2?
//	assign w_n = $signed(x_n) + $signed(prod_2[30:15]) - $signed(w_n_2);
//	assign prod_3 = sinw0 * w_n_1;
//	
//	assign q_sin = $signed(prod_3[30:15]);
//	assign q_cos = $signed(w_n) - $signed(prod_1[30:15]);
//	assign q_prod_1 = prod_1;
//	assign q_prod_2 = prod_2;
	
endmodule

