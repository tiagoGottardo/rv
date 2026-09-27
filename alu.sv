module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] op,
    output reg [31:0] result,
    output reg zero
);

  wire [4:0] b_part = b[4:0];

  always_comb begin
    case (op)
      4'd0: result = a + b;
      4'd1: result = a - b;
      4'd2: result = a & b;
      4'd3: result = a | b;
      4'd4: result = a ^ b;
      4'd5: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
      4'd6: result = (a < b) ? 32'b1 : 32'b0;
      4'd7: result = a << b_part;
      4'd8: result = a >> b_part;
      4'd9: result = $signed(a) >>> b_part;
      default: result = 0;
    endcase

    zero = (result == 0);
  end

endmodule
