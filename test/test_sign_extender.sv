module test_sign_extender;
  logic [31:0] inst;
  logic [ 6:0] opcode;
  logic [31:0] imm;

  sign_extender dut (
      .inst(inst),
      .opcode(opcode),
      .imm(imm)
  );

  task automatic check(input string name, input [31:0] instruction, input [6:0] op,
                       input [31:0] expected);
    inst   = instruction;
    opcode = op;
    #1;
    if (imm !== expected) $fatal(1, "%s: got %h, expected %h", name, imm, expected);
  endtask

  initial begin
    check("negative i immediate", 32'hfff00000, 7'b0010011, 32'hffffffff);
    check("positive s immediate", {7'h09, 13'b0, 5'h05, 7'b0100011}, 7'b0100011, 32'h00000125);
    check("negative b immediate", {1'b1, 6'b111111, 13'b0, 4'b1111, 1'b1, 7'b1100011},
          7'b1100011, 32'hfffffffe);
    check("u immediate", 32'habcde000, 7'b0110111, 32'habcde000);
    check("positive j immediate", {1'b0, 10'h001, 1'b0, 8'h01, 5'b0, 7'b1101111},
          7'b1101111, 32'h00001002);
    check("unknown opcode", 32'hffffffff, 7'b0000000, 32'b0);
  end
endmodule
