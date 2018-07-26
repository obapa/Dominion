//Author:	Patrick  O'Banion
//notes:	controller for the card_handler
module card_control(
	input clk, reset, e, but_sel,
	input [2:0] mode,
	output reg handle_clr
	);

	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;

	reg [2:0] prev_mode;

	task res; begin
		handle_clr <= 1;
		prev_mode <= 0;
	end endtask

	initial begin
		res;
	end

	always @(posedge clk, negedge reset) begin
		if (reset == 0) begin
			res;
		end
		else begin
			if(prev_mode != mode) begin //reset when mode changes
				handle_clr <= 1;
				prev_mode <= mode;
			end
			else begin
				handle_clr <= 0; 
			end
		end//if e then dont mess with anything
	end
	
endmodule
