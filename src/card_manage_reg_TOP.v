module card_manage_reg_TOP (
	input clk, reset, but_sel, draw,
	input [1:0] mode,
	input [15:0] card_sel_sw,
	output [5:0] deck_size, discard_size,
	output [3:0] card_stream
	);
		
		wire [3:0] address, deck;
		reg [3:0] data;
		reg wren = 1;


		switch_decode sd(card_sel_sw, address);
		Deck deckRAM(address,clk,data,wren,deck);
		
endmodule
		