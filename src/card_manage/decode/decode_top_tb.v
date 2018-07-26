`timescale 10ns/10ns
module decode_top_tb();

	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;

	reg clk, reset;
	reg [2:0] mode;
	reg [3:0] card_stream;
	reg [4:0] gold_in_bank;
	wire [2:0] buy, action, draw;
	wire [4:0] gold;//tells vp in ENDGAME mode
	wire [7:0] name;
	wire nextcard;

	decode_TOP tb(clk, reset, mode, card_stream, gold_in_bank, 
		buy, action, draw, gold, name, nextcard);
	always begin
		clk <= 0; #10;
		clk <= 1; #10;
	end
	initial begin
		#1; reset = 1; mode = ACTION; card_stream = 6; gold_in_bank = 10; #100;
		card_stream = 11; #100;
		mode = BUY; card_stream = 11;
	
	end


endmodule
