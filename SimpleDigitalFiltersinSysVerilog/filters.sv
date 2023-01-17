module filters
(
	input logic clk,
	input logic reset_n,
	input logic signed [15:0] d,
	output logic signed [15:0] q_filter1,
	output logic signed [15:0] q_filter2
);

	logic signed [15:0] d_del;
	logic signed [15:0] q_del_filter1;
	logic signed [15:0] q_del_filter2;
	
	always_ff@(posedge clk)
	if(0 == reset_n)
	begin
		d_del <= 0;
		q_del_filter1 <= 0;
		q_del_filter2 <= 0;
	end
	else
	begin
		d_del <= d;
		q_del_filter1 <= q_filter1;
		q_del_filter2 <= q_filter2;
	end
	
	// y[n] = x[n] + y[n-1]
	logic signed [16:0] y_n_filter1;
	assign y_n_filter1 = $signed(d) + $signed(q_del_filter1);
	assign q_filter1 = y_n_filter1[15:0];
	
	// y[n] = x[n] - x[n-1]
	logic signed [16:0] y_n_filter2;
	assign y_n_filter2 = $signed(d) - $signed(d_del);
	assign q_filter2 = y_n_filter2[15:0];
	
endmodule
