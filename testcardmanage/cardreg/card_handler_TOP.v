module card_control_TOP (
	input clk, reset, but_sel, can_buy, 
	input [2:0] mode,
	input [15:0] card_sel_sw,
	output [3:0] card_stream,
	output [7:0] deck_count, discard_count,
	output end_mode, next_card
	);
	
	wire [3:0] card_sel;
	wire e, handle_clr;
	
	//decodes the 16 input switches to 4bit card_sel, outputs e if multiple switches pressed
	switch_decode sd(card_sel_sw, card_sel, e);

	//controls the RAM and how it acts
	card_handler_reg chr(clk, reset, but_sel, handle_clr, can_buy, mode, card_sel, deck_count, discard_count, card_stream, end_mode, next_card);
	card_control cc(clk, reset, e, but_sel, mode, handle_clr);

endmodule