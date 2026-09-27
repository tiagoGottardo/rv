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

    check_alu("It should test sum correctly", 32'd23, 32'd23, 4'd0, 32'd46, 1'b0);
    check_alu("It should test sum correctly 2", 32'd23, 32'd23, 4'd0, 32'd46, 1'b1);
    // check_alu("It should test sum correctly", 32'd23, 32'd23, 4'd0, 32'd0, 1);

    // $urandom_range(0, 3)
  end

endmodule
