module mux2 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        sel,
    output logic [31:0] y
);
  always_comb begin
    y = sel ? b : a;
  end
endmodule
