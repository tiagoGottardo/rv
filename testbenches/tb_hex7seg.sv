module tb_hex7seg;
  logic [3:0] value;
  logic [6:0] segments_n;

  hex7seg dut (.*);

  task automatic check(input [3:0] digit, input [6:0] expected);
    value = digit;
    #1;
    if (segments_n !== expected)
      $fatal(1, "digit %h: got %07b, expected %07b", digit, segments_n, expected);
  endtask

  initial begin
    check(4'h0, 7'b1000000);
    check(4'h1, 7'b1111001);
    check(4'h2, 7'b0100100);
    check(4'h3, 7'b0110000);
    check(4'h4, 7'b0011001);
    check(4'h5, 7'b0010010);
    check(4'h6, 7'b0000010);
    check(4'h7, 7'b1111000);
    check(4'h8, 7'b0000000);
    check(4'h9, 7'b0010000);
    check(4'ha, 7'b0001000);
    check(4'hb, 7'b0000011);
    check(4'hc, 7'b1000110);
    check(4'hd, 7'b0100001);
    check(4'he, 7'b0000110);
    check(4'hf, 7'b0001110);
  end
endmodule
