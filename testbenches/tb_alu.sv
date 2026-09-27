import log_pkg::*;

interface alu_if;
  logic [31:0] a;
  logic [31:0] b;
  logic [ 3:0] op;
  logic [31:0] result;
  logic        zero;
endinterface

module tb_alu;

  alu_if vif ();

  alu dut (
      .a(vif.a),
      .b(vif.b),
      .op(vif.op),
      .result(vif.result),
      .zero(vif.zero)
  );

  task check_alu(input string test_name, input [31:0] a, input [31:0] b, input [3:0] op,
                 input [31:0] result, input zero);
    vif.a  = a;
    vif.b  = b;
    vif.op = op;

    #1;

    if (vif.result === result && vif.zero === zero) pass(test_name);
    else if (vif.result !== result)
      fail(test_name, $sformatf("Result Output=%0b, Expected=%0b", vif.result, result));
    else fail(test_name, $sformatf("Zero Output=%0b, Expected=%0b", vif.zero, zero));
  endtask

  initial begin
    check_alu("It should sum correctly", 32'd23, 32'd23, 4'd0, 32'd46, 1'b0);
    check_alu("It should result 0", 32'b10000000000000000000000000000000,
              32'b10000000000000000000000000000000, 4'd0, 0, 1'b1);
    check_alu("It should sub correctly", 32'd23, 32'd21, 4'd1, 32'd2, 1'b0);
    check_alu("It should and correctly", 32'd8, 32'd10, 4'd2, 32'd8, 1'b0);
    check_alu("It should or correctly", 32'd8, 32'd10, 4'd3, 32'd10, 1'b0);
    check_alu("It should xor correctly", 32'd8, 32'd10, 4'd4, 32'd2, 1'b0);
    check_alu("It should check signed lt correctly", 32'b10000000000000000000000000000010,
              32'b00000000000000000000000000000001, 4'd5, 32'd1, 1'b0);
    check_alu("It should check unsigned lt correctly", 32'b10000000000000000000000000000010,
              32'b10000000000000000000000000000001, 4'd6, 32'd0, 1'b1);
    check_alu("It should shift left correctly", 32'b00000000000000000000000000000001, 32'd3, 4'd7,
              32'b00000000000000000000000000001000, 1'b0);
    check_alu("It should shift right correctly", 32'b00000000000000000000000000001000, 32'd4, 4'd8,
              0, 1'b1);
    check_alu("It should shift right arithmetic", 32'b10000000000000000000000000001000, 32'd3, 4'd9,
              32'b11110000000000000000000000000001, 1'b0);
  end

endmodule
