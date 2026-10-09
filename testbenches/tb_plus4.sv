module tb_plus4;
  logic [31:0] a;
  logic [31:0] y;

  plus4 dut (
      .a(a),
      .y(y)
  );

  initial begin
    a = 32'h00000000;
    #1;
    if (y !== 32'h00000004) $fatal(1, "zero: got %h", y);

    a = 32'hfffffffc;
    #1;
    if (y !== 32'h00000000) $fatal(1, "wraparound: got %h", y);
  end
endmodule
