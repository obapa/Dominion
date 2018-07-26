//Author:	Patrick O'Banion
//outputs the values recieved on the inputs for the corresponing modes
module decode_output(	
	input card_go,
	input [2:0] mode,
	input [2:0] ibuy, iaction, idraw,
	input [4:0] igold,
	input [3:0] ivp, icost,
	input can_buy,
	output reg [2:0] obuy, oaction, odraw,
	output reg [4:0] ogold//tells vp in ENDGAME mode
	);

	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;

	always @(card_go) begin		
		//---------------- default data --------------------//
		obuy = 0;
		oaction = 0;
		odraw = 0;
		ogold = 0;
		//---------------- begin states --------------------//
		if(card_go == 1) begin
			case (mode) 
				BUY: begin					
					if (can_buy) begin
					 	ogold = {1,icost};
					end
				end
				ENDGAME: begin //output vp
					ogold = {ivp[3],0,ivp[2:0]};
				end
				ACTION: begin //output card stats
					obuy = ibuy;
					oaction = iaction;
					odraw = idraw;
					ogold = igold;
				end
				ACTIONEND: begin
					ogold = igold;
				end
				default: begin end
			endcase
		end
	end
endmodule
