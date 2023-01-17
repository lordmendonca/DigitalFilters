module digital_resonator
(
	input logic clk,
	input logic reset_n,
	input logic signed [15:0] d,
	output logic signed [15:0] q
);

	localparam SYTEM_FREQUENCY = 50000000;
	localparam SAMPLING_FREQUENCY = 500;
	localparam CLOCK_TICKS = SYTEM_FREQUENCY/SAMPLING_FREQUENCY;
	
	localparam BITWIDTH = $clog2(CLOCK_TICKS);
	
	logic [BITWIDTH : 0] time_base =0;
	
	always_ff@(posedge clk)
	begin
		if(0 == reset_n)
			time_base <= 0;
		else
			time_base <= (time_base + 1) % CLOCK_TICKS;
	end

	logic enable;
	assign enable = (time_base == (CLOCK_TICKS - 1'b1))? 1'b1 : 1'b0;
	
	//Q8.8 format
	localparam signed [15:0] b = 16'b0000000100000000;
	//BW = 0.02, a = (1 - BW/2)
	//a0 = 2*a*cos(2*pi*fr/fs), fr = 200/(2*pi), fs = 500
	//a0 = 0.99
	//a1 = a^2 = 0.9801
	localparam signed [15:0] a0 = 16'b0000000111010011;
	localparam signed [15:0] a1 = 16'b0000000011111011;
	
	logic [15:0] x_del [3:0];
	logic [15:0] y_del [3:0];
	integer i;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
	begin
		for(i = 0; i <= 2; i = i + 1)
		begin
			x_del[i] <= 0;
			y_del[i] <= 0;
		end
	end
	else
	begin
		for(i = 0; i <= 2; i = i + 1)
		begin
			if(0 == i)
			begin
				x_del[i] <= d;
				y_del[i] <= q;
			end
			else
			begin
				x_del[i] <= x_del[i-1];
				y_del[i] <= y_del[i-1];
			end
		end
	end
	
	logic [31:0] prod_1, prod_2, prod_3;
	//b * (x[n] - x[n-2])
	logic [15:0] x_n, x_n_2;
	logic [15:0] diff_1;
	assign x_n = x_del[0];
	assign x_n_2 = x_del[2];
	assign diff_1 = x_n - x_n_2;
	assign prod_1 = b * diff_1;
	
	//(2*a*cos(2*pi*fr/fs)) * y[n-1]
	logic [15:0] y_n_1;
	assign y_n_1 = y_del[1];
	assign prod_2 = a0 * y_n_1;
	
	//(a*a) * y[n-2]
	logic [15:0] y_n_2;
	assign y_n_2 = y_del[2];
	assign prod_3 = a1 * y_n_2;
	
	assign q = $signed(prod_1[30:15]) + $signed(prod_2[30:15]) - $signed(prod_3[30:15]);
	
endmodule
