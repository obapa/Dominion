//Course Number: 	ECE5440
//Author: 		Patrick O'Banion #2916
//---------------------------------------//
//Description:		Splits the card data recieved from the ram into the proper fields
//---------------------------------------//
module decode(
	input [29:0] card_data,
	output reg [2:0] buy, action, draw,
	output reg [4:0] gold,//tells vp in ENDGAME mode
	output reg [3:0] vp, cost,
	output reg [7:0] name
	);
	
	always @(card_data) begin
		gold = card_data[30:25];
		buy = card_data[24:22];
		action = card_data[21:19];
		draw = card_data[18:16];
		vp = card_data[15:12];
		cost = card_data[11:8];
		name = card_data[7:0];
	end

endmodule