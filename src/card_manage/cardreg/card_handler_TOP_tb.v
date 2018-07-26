`timescale 1ns/1ns
module card_handler_TOP_tb ();
	
	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;	

	reg clk, reset, but_sel, can_buy; 
	reg [2:0] mode;
	reg [15:0] card_sel_sw;
	wire broadcasting;
	wire [3:0] card_stream;
	wire [7:0] discard_count, hand_count;
	wire [3:0] hand_count;

	card_control_TOP tb( clk, reset, but_sel, can_buy, mode, card_sel_sw, 
			card_stream, deck_count, discard_count, hand_count, end_mode, next_card);

	always begin
		clk <= 0; #10;
		clk <= 1; #10;
	end
	
	initial #1 begin
		reset <= 1; but_sel <= 0; can_buy <= 0;
		mode <= START; card_sel_sw <= 1; #2000;
		mode <= ENDGAME;
	end

endmodule
