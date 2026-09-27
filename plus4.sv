module plus4 (
    input  wire [31:0] a,
    output wire [31:0] y
);
  always_comb begin
    y = a + 4;
  end
endmodule
