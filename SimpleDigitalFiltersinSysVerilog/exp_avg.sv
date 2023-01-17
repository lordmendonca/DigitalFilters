module exp_avg
(
	input logic clk,
	input logic reset_n,
	input logic signed [15:0] d,
	output logic signed [15:0] q,
	output logic signed [15:0] q_simplified,
	output logic signed [15:0] q_mulSimplified
);

	//localparam signed [15:0] alpha = 16'sb0000110011001101;	//a=0.1
	//localparam signed [15:0] c_alpha = 16'sb0111001100110011; //a=0.9
	
	localparam signed [15:0] alpha = 16'sb0001000000000000;		//0.125
	localparam signed [15:0] c_alpha = 16'sb01110000000000001;	//0.875
	
	//y[n] = a * x[n] + (1-a) * y[n-1]
	logic signed [15:0] del;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
		del <= 0;
	else
		del <= q;
	
	logic signed [31:0] prod_1, prod_2;
	assign prod_1 = d * alpha;
	assign prod_2 = del * c_alpha;
	
	assign q = $signed(prod_1[30:15]) + $signed(prod_2[30:15]);
	
	//y[n] = a * (x[n] - y[n-1])+ y[n-1] 
	logic signed [15:0] del_simplified;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
		del_simplified <= 0;
	else
		del_simplified <= q_simplified;
	
	//y[n] = a * (x[n] - y[n-1]) + y[n-1]
	logic signed [15:0] diff;
	assign diff = (d - del_simplified);
	
	logic signed [31:0] prod_3;
	assign prod_3 = diff * alpha;
	
	assign q_simplified = $signed(prod_3[30:15]) + $signed(del_simplified);
	
	//multiplier free
	
	localparam L = 2;
	localparam M = 3;
	
	logic signed [15:0] del_mulSimplified;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
		del_mulSimplified <= 0;
	else
		del_mulSimplified <= q_mulSimplified;
	
	
	logic signed [15:0] shiftL;
	assign shiftL = $signed(diff[15:L]);
	
	logic signed [15:0] shiftM;
	assign shiftM = $signed(diff[15:M]);
	
	assign q_mulSimplified = $signed(shiftL) - $signed(shiftM) + $signed(del_mulSimplified);

endmodule
