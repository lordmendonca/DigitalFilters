module digital_resonator(
	input logic clk, input logic reset_n, input logic enable,							 
	input  logic signed [15:0] d, 
	output logic signed [15:0] q		
	);
	
	// difference equation to be implemented: y(n) = -1.8403*y(n-1) + 0.9980*y(n-2) + 0.0009995*x(n) - 0.0009995*x(n-2)
	
	// scaled by 0.25 to fit to Q1.15: 0.25*y(n) = -0.460075*y(n-1) + 0.2495*y(n-2) + 0.000249875*x(n) - 0.000249875*x(n-2)
	//											   a0* y(n) =        a1*y(n-1) +     a2*y(n-2) +          b0*x(n) +          b2*x(n-2)
	
	// Q1.15: use bin(fi(X,1,16,15,'RoundingMethod', 'Floor')) 			
				
	localparam signed [15:0] b0  = 16'sb0000000000001000;		// bin(fi(+0.000249875,1,16,15,'RoundingMethod', 'Floor')) 
	localparam signed [15:0] b2  = 16'sb1111111111110111;		// bin(fi(-0.000249875,1,16,15,'RoundingMethod', 'Floor')) 
	// a0 scaling happens at the end in  terms of shifting ... 
	localparam signed [15:0] a1  = 16'sb1100010100011100;		// bin(fi(-0.460075000,1,16,15,'RoundingMethod', 'Floor'))
	localparam signed [15:0] a2  = 16'sb0001111111101111;		// bin(fi(+0.249500000,1,16,15,'RoundingMethod', 'Floor'))
	
	// difference equation to be implemented: y(n) = -1.8237*y(n-1) + 0.9801*y(n-2) + 0.0009995*x(n) - 0.0009995*x(n-2)
	// scaled by 0.25 to fit to Q1.15: 0.25*y(n) = -0.455925*y(n-1) + 0.245025*y(n-2) + 0.000249875*x(n) - 0.000249875*x(n-2)
	//											   a0* y(n) =        a1*y(n-1) +     a2*y(n-2) +          b0*x(n) +          b2*x(n-2)		
	
	//a=0.99
	// a0 scaling happens at the end in  terms of shifting ... 
	//localparam signed [15:0] a1  = 16'sb1100010110100100;		// bin(fi(-0.455925,1,16,15,'RoundingMethod', 'Floor'))
	//localparam signed [15:0] a2  = 16'sb0001111101011101;		// bin(fi(+0.245025,1,16,15,'RoundingMethod', 'Floor'))
	
	//a=0.999969482421875
	//localparam signed [15:0] a1  = 16'sb1100010100001110;		// bin(fi(-0.460075000,1,16,15,'RoundingMethod', 'Floor'))
	//localparam signed [15:0] a2  = 16'sb0010000000000000;		// bin(fi(+0.249500000,1,16,15,'RoundingMethod', 'Floor'))
	
	// current output: y(n) 
	logic signed [15:0] y_n;	

	// delayed output: y(n) --> y(n_1)
	logic signed [15:0] y_n_1 = 16'sd0;
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			y_n_1 <= 0;
		else if(enable)
			y_n_1 <= y_n;
			
	// delayed output: y(n_1) --> y(n_2)
	logic signed [15:0] y_n_2 = 16'sd0;
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			y_n_2 <= 0;
		else if(enable)
			y_n_2 <= y_n_1;
	
	// delayed input: x(n_1)
	logic signed [15:0] x_n_1 = 16'sd0;
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			x_n_1 <= 0;
		else if(enable)
			x_n_1 <= d;		

	// delayed input: x(n_2)		
	logic signed [15:0] x_n_2 = 16'sd0;
	always_ff@(posedge clk)
		if(reset_n == 1'b0)
			x_n_2 <= 0;
		else if(enable)
			x_n_2 <= x_n_1;
			
	// now, all coefficients are multiplied with the respective input/putput samples 
	logic signed [31:0] b0_x_n;    assign b0_x_n    = b0 * d;	
	logic signed [31:0] b2_x_n_2;  assign b2_x_n_2  = b2 * x_n_2;	
	logic signed [31:0] a1_y_n_1;  assign a1_y_n_1  = a1 * y_n_1;		
	logic signed [31:0] a2_y_n_2;  assign a2_y_n_2  = a2 * y_n_2;	
							
	// scale back all products from Q2.30 to Q1.15 
	logic signed [15:0] tmp_x_n; 	 assign tmp_x_n   =  $signed(b0_x_n[30:15]);
	logic signed [15:0] tmp_x_n_2; assign tmp_x_n_2 =  $signed(b2_x_n_2[30:15]);
	logic signed [15:0] tmp_y_n_1; assign tmp_y_n_1 =  $signed(a1_y_n_1[30:15]);
	logic signed [15:0] tmp_y_n_2; assign tmp_y_n_2 =  $signed(a2_y_n_2[30:15]);
		
	// compute the current y(n) output and scale it back to original size 
	// (multiplied with 4)
	
	assign y_n = (-tmp_y_n_1 - tmp_y_n_2 + tmp_x_n + tmp_x_n_2) <<< 2;

	assign q = y_n;
		
endmodule
