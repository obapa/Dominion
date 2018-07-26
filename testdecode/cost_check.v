//checks if the cost of a card is less than the available money
module cost_check(
	input [4:0] gold_in_bank,
	input [3:0] cost,
	output reg valid
	);

	always @(cost, gold_in_bank) begin
		if (cost < gold_in_bank) valid = 1; 
		else valid = 0;
	end

endmodule