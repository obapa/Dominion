module card_handler_reg (
	input clk, reset, but_sel, handle_clr, can_buy,
	input [2:0] mode,
	input [3:0] card_sel,
	output reg [5:0] deck_size, discard_size,
	output reg [3:0] hand_size,
	output reg [3:0] card_stream,
	output reg end_mode, next_card
	);

	parameter START = 1, ACTION = 2, ACTIONEND = 3, BUY = 4, DRAW = 5, ENDGAME  = 6;		
	parameter WAIT = 0, GO = 1, NO = 3;//to wait for ram to load
	parameter INIT_DISCARD_STATE = 0, INIT_DECK_STATE = 1, INIT_HAND_STATE = 2;
	parameter DECK_SIZE_STATE = 0, DISCARD_SIZE_STATE = 1, HAND_SIZE_STATE = 2, DISCARD_HAND_STATE = 3, DRAW_HAND_STATE = 4;
	parameter GET_HAND_DATA_STATE = 0, WRITE_HAND_TO_DISCARD_STATE = 1;
	parameter LOAD_DECK_STATE = 0, WRITE_DECK_TO_HAND_STATE = 1, SHUFFLE_DECK_STATE = 2;
	parameter LOAD_CARD_STATE = 0, CHECK_CARD_STATE = 1, SET_CARD_STATE = 2, COMPACT_HAND_STATE = 3;
	parameter GET_DISCARD_SIZE_STATE = 0, BUY_CARD_STATE = 1, ACTION_CARD_STATE = 1;
	parameter VP_DISCARD_STATE = 0, VP_DECK_STATE = 1, VP_HAND_STATE = 2;
	
	reg wren_deck, wren_discard, wren_hand;
	wire[3:0] q_deck, q_discard, q_hand;
	reg [3:0] ddata;
	reg [3:0] hdata;
	reg [5:0] adr_ptr;
	reg pause;//for initializing deck
	reg [2:0] wait_for_RAM;
	reg load_adr;
	reg button_done;
	reg prev_but;
	reg [2:0] wait1;
	reg init_deck;
	reg init_discard;
	reg init_hand;
	reg found_end_deck;
	reg found_end_discard;
	reg found_end_hand;
	reg [3:0] save_card;
	reg [3:0] empty_address;
	reg discard_hand;
	reg draw_hand;
	reg [2:0] inner_draw_state;
	reg [3:0] draw_state;
	reg [2:0] state;
	reg [3:0] init_state;
	reg [2:0] buy_state;
	reg [2:0] action_state;
	reg [2:0] compact_state;
	reg [2:0] endgame_state;

	reg [6:0] d_address;
	reg [3:0] h_address;

	RAMDeck deck (d_address,clk,ddata,wren_deck,q_deck);
	RAMDiscard discard (d_address,clk,ddata,wren_discard,q_discard);
	RAMHand hand (h_address,clk,hdata,wren_hand,q_hand);
		
	task res; begin
		wren_deck <= 0;//set all registers to read
		wren_discard <= 0;
		wren_hand <= 0;
		adr_ptr <= 0;
		pause <= 0;
		wait_for_RAM <= NO;
		load_adr <= 0;
		wait1 <= 0;
		button_done <= 1;
		end_mode <= 0;
		init_deck <= 0;
		init_discard <= 0;
		init_hand <= 0; 
		found_end_deck <= 0;
		found_end_discard <= 0;
		found_end_hand <= 0;
		hdata <= 15;
		ddata <= 15;
		discard_hand <= 0;
		draw_hand <= 0;
		init_state <= INIT_DISCARD_STATE;
		state <= LOAD_CARD_STATE;
		draw_state <= DECK_SIZE_STATE;
		inner_draw_state <= GET_HAND_DATA_STATE;
		compact_state <= 0;
		save_card <= 15;
		action_state <= GET_DISCARD_SIZE_STATE;
		buy_state <= GET_DISCARD_SIZE_STATE;
		endgame_state <= VP_DISCARD_STATE;
	end endtask

	initial begin
		res;
	end

	always @ (posedge clk, negedge reset) begin
		if (handle_clr == 1 || reset == 0) begin
			res;
		end//else if !e
		else begin
			if (wait_for_RAM == GO) begin//||wait_for_RAM == NO
				pause <= 0;
			end
			else begin
				case (mode)
					START: begin //initialize discard to be 7 copper 3 estates, all other mem to be 15 (null)
						if ( pause == 0 && end_mode == 0) begin 
							case(init_state) 
								INIT_DISCARD_STATE: begin
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											d_address <= adr_ptr;
											wren_discard <= 0;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= SET_CARD_STATE;
											end 
											else begin
												init_state <= INIT_DECK_STATE;
												adr_ptr <= 0;
												state <= LOAD_CARD_STATE;
											end
										end
										SET_CARD_STATE: begin
											wren_discard <= 1;
											pause <= 1;
											case (d_address) //initialize starting hand
												0,1,2,3,4,5,6 : begin
													ddata <= 0;//copper
												end
												7,8,9 : begin
												ddata <= 3;//estate
												end							
												default: begin
													ddata <= 15;//null
												end
											endcase
											state <= LOAD_CARD_STATE;
										end
										default : begin
											state <= LOAD_CARD_STATE;
										end
									endcase
								end
								INIT_DECK_STATE: begin
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											d_address <= adr_ptr;
											wren_deck <= 0;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= SET_CARD_STATE;
											end 
											else begin
												init_state <= INIT_HAND_STATE;
												adr_ptr <= 0;
												state <= LOAD_CARD_STATE;
											end
										end
										SET_CARD_STATE: begin
											wren_deck <= 1;
											pause <= 1;
											ddata <= 15;//initialize to null
											state <= LOAD_CARD_STATE;
										end
										default begin
											state <= LOAD_CARD_STATE;
										end
									endcase
								end	
								INIT_HAND_STATE: begin
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											h_address <= adr_ptr;
											wren_hand <= 0;
											if (adr_ptr < 14) begin
												adr_ptr <= adr_ptr + 1;
												state <= SET_CARD_STATE;
											end 
											else begin
												end_mode <= 1;
												adr_ptr <= 0;
												state <= LOAD_CARD_STATE;
											end
										end
										SET_CARD_STATE: begin
											wren_hand <= 1;
											pause <= 1;
											hdata <= 15;//initialize to null
											state <= LOAD_CARD_STATE;
										end
										default : begin
											state <= LOAD_CARD_STATE;
										end
									endcase
								end
								default : begin
									init_state <= INIT_DISCARD_STATE;
								end
							endcase
						end
					end
					ACTION: begin //send hand[card_sel] to card_stream on but_sel
						if (pause == 0) begin
							case(action_state)
								GET_DISCARD_SIZE_STATE: begin
									case (state) //get discard size
										LOAD_CARD_STATE: begin
											pause <= 1;
											d_address <= adr_ptr;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= CHECK_CARD_STATE;
											end 
											else begin
												action_state <= ACTION_CARD_STATE;
												state <= LOAD_CARD_STATE;
											end
										end
										CHECK_CARD_STATE: begin
											if(q_discard == 15) begin
												discard_size <= d_address;
											end
											else begin
												state <= LOAD_CARD_STATE;
											end
										end
									endcase
								end
								ACTION_CARD_STATE: begin
									case (state) 
										LOAD_CARD_STATE: begin
											next_card <= 0;
											if(but_sel == 1) begin//load card on but press
												pause <= 1;
												h_address <= card_sel;
												d_address <= discard_size;
												wren_hand <= 0;
												wren_discard <= 0;
												state <= CHECK_CARD_STATE;
											end
											else begin
												state <= LOAD_CARD_STATE;
											end
										end
										CHECK_CARD_STATE: begin//output card we selected
											pause <= 1;	
											card_stream <= q_hand;
											state <= SET_CARD_STATE;
											next_card <= 1;
										end
										SET_CARD_STATE: begin
											pause <= 1;
											next_card <= 0;
											wren_discard <= 1;//copy card to discard
											ddata <= q_hand;
											wren_hand <= 1;//set card to null in hand
											hdata <= 15;
											state <= LOAD_CARD_STATE;
										end
										/*COMPACT_CARD_STATE: begin//remove card from hand
										next_card <= 0;
										wren_discard <= 0;
										case (compact_state) begin
											LOAD_CARD_STATE: begin//load ram to empty location
												pause <= 1;
												if(h_address + 1 < 15) begin
													state <= CHECK_CARD_STATE;
												end
												else begin
													state <= LOAD_CARD_STATE;
												end
												wren_hand <= 0;
											end
											CHECK_CARD_STATE: begin
												pause <= 1;	
												save_card <= q_hand;
												wren_hand <= 1;
												state <= SET_CARD_STATE;
												h_address <= h_address + 1;
											end
											SET_CARD_STATE: begin
												pause <= 1;
												wren_hand <= 1;
												pause <= 1;
												hdata <= 15;//initialize to null
												state <= LOAD_CARD_STATE;
											end
										endcase
									end*/
									endcase
								end
							endcase
						end
					end
					ACTIONEND: begin //loop through remaining hand and send all through card_stream
						if (pause == 0 && end_mode == 0) begin
							case (state) 
								LOAD_CARD_STATE: begin
									pause <= 1;
									next_card <= 0;
									h_address <= adr_ptr;
									if (adr_ptr < 15) begin
										adr_ptr <= adr_ptr + 1;
										state <= CHECK_CARD_STATE;
									end 
									else begin
										end_mode <= 1;
									end
								end
								CHECK_CARD_STATE: begin
									card_stream <= q_hand;
									state <= LOAD_CARD_STATE;
									next_card <= 1;
								end
							endcase
						end
					end
					BUY: begin //add card_sel to end of discard on but_sel if can_buy == 1
						if (pause == 0) begin
							case(buy_state)
								GET_DISCARD_SIZE_STATE: begin
									case (state) //get discard size
										LOAD_CARD_STATE: begin
											pause <= 1;
											d_address <= adr_ptr;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= CHECK_CARD_STATE;
											end 
											else begin
												buy_state <= BUY_CARD_STATE;
												state <= LOAD_CARD_STATE;
											end
										end
										CHECK_CARD_STATE: begin
											if(q_discard == 15) begin
												discard_size <= d_address;
											end
											else begin
												state <= LOAD_CARD_STATE;
											end
										end
									endcase
								end
								BUY_CARD_STATE: begin
									case (state) 
										LOAD_CARD_STATE: begin
											if(but_sel == 1) begin
												pause <= 1;
												h_address <= adr_ptr;
												wren_discard <= 0;
												state <= SET_CARD_STATE;
												ddata <= card_sel;
												next_card <= 0;
											end
											else begin
												state <= LOAD_CARD_STATE;
											end
										end
										SET_CARD_STATE: begin
											if(can_buy == 1) begin
												wren_discard <= 1;
												pause <= 1;
												state <= LOAD_CARD_STATE;
												next_card <= 1;
											end
										end
									endcase
								end
							endcase
						end
					end
					DRAW: begin //but hand -> discard, deck -> hand, need to check for when to shuffle, also need to include draw on draw durring action
						if(pause == 0 && end_mode == 0) begin
							case (draw_state)
								DECK_SIZE_STATE: begin //get deck size size
									pause <= 1;
									d_address <= adr_ptr;
									if (adr_ptr < 127) begin
										d_address <= adr_ptr;
										adr_ptr <= adr_ptr + 1;
									end 
									else begin
										discard_size <= 127;
										found_end_deck <= 1;	
										adr_ptr <= 0;					
									end
									if (q_deck == 15) begin
										deck_size <= adr_ptr - 1;
										draw_state <= DISCARD_SIZE_STATE;
										adr_ptr <= 0;
									end
								end
								DISCARD_SIZE_STATE: begin //get discard size
									pause <= 1;
									d_address <= adr_ptr;
									if (adr_ptr < 127) begin
										d_address <= adr_ptr;
										adr_ptr <= adr_ptr + 1;
									end 
									else begin
										discard_size <= 127;
										found_end_discard <= 1;						
									end
									if (q_discard == 15) begin
										discard_size <= adr_ptr - 1;
										draw_state <= HAND_SIZE_STATE;
									end
								end
								HAND_SIZE_STATE: begin //get hand size
									/*pause <= 1;
									d_address <= adr_ptr;
									if (adr_ptr < 15) begin
										adr_ptr <= adr_ptr + 1;
									end 
									else begin
										hand_size <= 15;
										found_end_hand <= 1;						
									end
									if (hand_q == 15) begin
										hand_size <= adr_ptr - 1;
										draw_state <= DISCARD_HAND_STATE;
									end*/
									hand_size <= 15;
									draw_state <= DISCARD_HAND_STATE;
								end
								DISCARD_HAND_STATE: begin //discard entire hand
									case (inner_draw_state)
										GET_HAND_DATA_STATE: begin//get card from hand
											pause <= 1;
											wren_hand <= 0;
											wren_deck <= 0;
											if(hand_size > 0) begin//start from last card in hand
												d_address <= discard_size;
												h_address <= hand_size;
												inner_draw_state <= WRITE_HAND_TO_DISCARD_STATE;
											end 
											else begin
												draw_state <= DRAW_HAND_STATE;
												inner_draw_state <= WRITE_DECK_TO_HAND_STATE;
												d_address <= 0;
												d_address <= 0;
											end
										end
										WRITE_HAND_TO_DISCARD_STATE: begin//copy card from hand to discard and clear it from hand
											if(q_hand != 15) begin//if not a null card in hand position
												pause <= 1;
												ddata <= q_hand;
												hdata <= 15;
												wren_hand <= 1;
												wren_deck <= 1;
												inner_draw_state <= GET_HAND_DATA_STATE;
												hand_size <= hand_size - 1;
												discard_size <= discard_size + 1;
											end
											else begin
												hand_size <= hand_size - 1;
											end
										end
									endcase
								end
								DRAW_HAND_STATE: begin //draw a new hand
									case (inner_draw_state) 
										LOAD_DECK_STATE: begin
											if (deck_size > 0) begin//if cards in deck
												if (hand_size < 5) begin//if hand needs cards
													wren_deck <= 0;
													wren_hand <= 0;
													pause <= 1;
													d_address <= d_address + 1;
													h_address <= h_address + 1;
													deck_size <= deck_size - 1;
													hand_size <= hand_size + 1;
													inner_draw_state <= WRITE_DECK_TO_HAND_STATE;
												end
												else begin
													end_mode <= 1;
												end
											end
											else begin//need to shuffle deck
												inner_draw_state <= SHUFFLE_DECK_STATE;								
											end
										end
										WRITE_DECK_TO_HAND_STATE: begin
											pause <= 1;
											wren_deck <= 1;
											wren_hand <= 1;
											hdata <= q_deck;
											ddata <= 15;
											inner_draw_state <= LOAD_DECK_STATE;
										end
										SHUFFLE_DECK_STATE: begin
										end
									endcase
								end
							endcase
						end
				end
					ENDGAME: begin //go through deck and send each card through card_stream to count vp
						if (pause == 0 && end_mode == 0) begin
							case(endgame_state)		
								VP_DISCARD_STATE: begin	
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											next_card <= 0;
											d_address <= adr_ptr;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= CHECK_CARD_STATE;
											end 
											else begin
												endgame_state <= VP_DECK_STATE;
												adr_ptr <= 0;
											end
										end
										CHECK_CARD_STATE: begin
											card_stream <= q_discard;
											state <= LOAD_CARD_STATE;
											next_card <= 1;
										end
									endcase
								end
								VP_DECK_STATE: begin	
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											next_card <= 0;
											d_address <= adr_ptr;
											if (adr_ptr < 127) begin
												adr_ptr <= adr_ptr + 1;
												state <= CHECK_CARD_STATE;
											end 
											else begin
												endgame_state <= VP_HAND_STATE;
												adr_ptr <= 0;
											end
										end
										CHECK_CARD_STATE: begin
											card_stream <= q_deck;
											state <= LOAD_CARD_STATE;
											next_card <= 1;
										end
									endcase
								end
								VP_HAND_STATE: begin	
									case (state) 
										LOAD_CARD_STATE: begin
											pause <= 1;
											next_card <= 0;
											d_address <= adr_ptr;
											if (adr_ptr < 15) begin
												adr_ptr <= adr_ptr + 1;
												state <= CHECK_CARD_STATE;
											end 
											else begin
												end_mode <= 1;
												adr_ptr <= 0;
											end
										end
										CHECK_CARD_STATE: begin
											card_stream <= q_hand;
											state <= LOAD_CARD_STATE;
											next_card <= 1;
										end
									endcase
								end
							endcase
						end
					end
				default: begin end
			endcase
			end
		end
	end


	//------------- Control for waiting on RAM -----------------//
	always @(posedge clk) begin
		if (pause == 1) begin
			case (wait_for_RAM)
				NO: begin
					wait_for_RAM <= WAIT;
				end
				GO: begin
					wait_for_RAM <= NO;			
				end
				default: begin 
					wait_for_RAM <= wait_for_RAM + 1;
				end
			endcase
		end 
		else begin
			wait_for_RAM <= NO;
		end
	end

endmodule
		