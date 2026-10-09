module plus4 (
    input  wire [31:0] a,
    output wire [31:0] y
);
  assign y = a + 32'd4;
endmodule
