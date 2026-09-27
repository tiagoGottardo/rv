module mux4 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [31:0] d,
    input  wire [ 1:0] sel,
    output reg  [31:0] y
);
  always_comb begin
    case (sel)
      4'd0: y = a;
      4'd1: y = b;
      4'd2: y = c;
      4'd3: y = d;
    endcase
  end
endmodule
