//Author:	Patrick O'Banion
//description:	Control for the decoder module, has a pause for the RAM
module decode_control(
	input clk, reset,
	input[2:0] mode,
	input [3:0] card_stream,
	output reg card_go,
	output reg nextcard
	);
	
	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;
	parameter WAIT = 0, GO = 1, PAUSE = 3, HOLD = 4;//to wait for ram to load
	
	reg [2:0] wait_for_RAM;
	reg [3:0] old_card_stream;
	
	//------------ When mode changes reset --------------------//
	always @(mode) begin
		wait_for_RAM <= PAUSE;
		old_card_stream <= 0;
		nextcard <= 0;
		card_go <= 0;
	end

	//------------- Control for waiting on RAM -----------------//
	always @(posedge clk, negedge reset) begin
		if (old_card_stream != card_stream) begin
			wait_for_RAM <= WAIT;
			old_card_stream <= card_stream;
			nextcard <= 0;
		end		
		else if (wait_for_RAM == GO) begin
			wait_for_RAM <= GO;
			nextcard <= 1;
			card_go <= 1;
		end 
		/*else if (wait_for_RAM == HOLD) begin
			wait_for_RAM <= HOLD;
			card_go <= 1;
		end*/
		else begin
			wait_for_RAM <= wait_for_RAM + 1;
			card_go <= 0;
		end
	end




endmodule