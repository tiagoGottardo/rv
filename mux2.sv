module mux2 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        sel,
    output reg  [31:0] y
);
  always_comb begin
    y = sel ? b : a;
  end
endmodule
