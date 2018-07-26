//Author:	Patrick O'Banion
//decodes the card address passed on the card stream, to the coresponding values and returns them
//when outputing nextcard = 1 then data for a new card is being sent
//also outputs can_buy when it is able to afford a card, used for cardmange module when buying to confirm that it is a valid purchase
module decode_TOP(input clk, reset,
	input [2:0] mode,
	input [3:0] card_stream,
	input [4:0] gold_in_bank,
	output [2:0] obuy, oaction, odraw,
	output [4:0] ogold,//tells vp in ENDGAME mode
	output [7:0] oname,
	output nextcard,
	output can_buy
	);
	
	wire [2:0] ibuy, iaction, idraw;
	wire [4:0] igold;
	wire [3:0] ivp, icost;
	wire [7:0] iname; 
	wire [29:0] card_data;
	wire card_go;
	
	//loads card data from ROM
	ROMCards cards(card_stream, clk, card_data);
	decode deco(card_data, ibuy, iaction, idraw, igold, ivp, icost, oname);
	
	//checks that we can buy the card when mode == BUY
	cost_check cc(gold_in_bank, icost, can_buy);
	
	//main control for module
	decode_control dc(clk, reset, mode, card_stream, card_go, nextcard);

	//gives output values for buy, action, draw, and gold
	decode_output do(card_go, mode, ibuy, iaction, idraw, igold, ivp, icost, can_buy, obuy, oaction, odraw, ogold);

	//I need display handler to show all cards in hand or shop
	
endmodule