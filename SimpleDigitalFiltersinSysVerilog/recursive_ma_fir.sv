// ESPS Lab - Implementation of an FIR Moving Average Filter

module recursive_ma_fir(
	input logic clk, input logic reset_n,
	input  logic signed [15:0] d,
	output logic signed [15:0] q_8tap,
	output logic signed [15:0] q_rma
	
	);
	
	logic signed [15:0] del [7:0];

	integer i;
	
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			for (i = 0; i <= 7; i = i+1) begin : clear_fir
				del[i] <= 0;
			end
		else
			for (i = 0; i <= 7; i = i+1) begin : shift
				if(i == 0)
					del[i] <= d;
				else
					del[i] <= del[i-1];
			end
	
	logic signed [18:0] sum; assign sum =  del[0] + del[1] + del[2] + del[3] + del[4] + del[5] + del[6] + del[7];
	
	assign q_8tap = $signed(sum[18:3]); 

	//Recursive MA
	
	logic signed [15:0] y_n_1;
	
	logic signed [15:0] x_n;
	assign x_n = del[0];
	
	logic signed [15:0] x_n_N;
	assign x_n_N = del[7];
		
	logic signed [18:0] diff;
	assign diff = x_n - x_n_N;
		
	logic signed [15:0] Navg;
	assign Navg = $signed(diff[18:3]);
		
	assign q_rma = y_n_1 + Navg;
	
	always_ff@(posedge clk)
	if(reset_n == 1'b0)
		 y_n_1 <= 15'd0;
	else
       y_n_1 <= q_rma;	
			
endmodule 