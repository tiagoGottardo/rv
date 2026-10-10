module tb_dcu;
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic       branch;
  logic       jump;
  logic       jump_register;
  logic [1:0] result_mux;
  logic       mem_write;
  logic       alu_src_a;
  logic       alu_src_b;
  logic       reg_write;
  logic [3:0] alu_op;

  wire [12:0] controls = {branch, jump, jump_register, result_mux, mem_write, alu_src_a,
                          alu_src_b, reg_write, alu_op};

  dcu dut (.*);

  task automatic check(input string name, input [6:0] op, input [2:0] f3, input [6:0] f7,
                       input [12:0] expected);
    opcode = op;
    funct3 = f3;
    funct7 = f7;
    #1;
    if (controls !== expected)
      $fatal(1, "%s: got %013b, expected %013b", name, controls, expected);
  endtask

  task automatic check_alu_immediate(input string name, input [2:0] f3, input [6:0] f7,
                                     input [3:0] operation);
    check(name, 7'b0010011, f3, f7, {3'b000, 2'b00, 3'b001, 1'b1, operation});
  endtask

  task automatic check_alu_register(input string name, input [2:0] f3, input [6:0] f7,
                                    input [3:0] operation);
    check(name, 7'b0110011, f3, f7, {3'b000, 2'b00, 3'b000, 1'b1, operation});
  endtask

  initial begin
    check("lui", 7'b0110111, 3'b000, 7'b0000000, {3'b000, 2'b11, 3'b000, 1'b1, 4'd0});
    check("auipc", 7'b0010111, 3'b000, 7'b0000000, {3'b000, 2'b00, 3'b011, 1'b1, 4'd0});
    check("jal", 7'b1101111, 3'b000, 7'b0000000, {3'b010, 2'b10, 3'b000, 1'b1, 4'd0});
    check("jalr", 7'b1100111, 3'b000, 7'b0000000, {3'b001, 2'b10, 3'b001, 1'b1, 4'd0});
    check("invalid jalr", 7'b1100111, 3'b001, 7'b0000000, 13'b0);

    check("beq", 7'b1100011, 3'b000, 7'b0000000, {3'b100, 2'b00, 3'b000, 1'b0, 4'd0});
    check("bltu", 7'b1100011, 3'b110, 7'b0000000, {3'b100, 2'b00, 3'b000, 1'b0, 4'd0});
    check("invalid branch", 7'b1100011, 3'b010, 7'b0000000, 13'b0);

    check("lw", 7'b0000011, 3'b010, 7'b0000000, {3'b000, 2'b01, 3'b001, 1'b1, 4'd0});
    check("lhu", 7'b0000011, 3'b101, 7'b0000000, {3'b000, 2'b01, 3'b001, 1'b1, 4'd0});
    check("invalid load", 7'b0000011, 3'b011, 7'b0000000, 13'b0);
    check("sw", 7'b0100011, 3'b010, 7'b0000000, {3'b000, 2'b00, 3'b101, 1'b0, 4'd0});
    check("invalid store", 7'b0100011, 3'b011, 7'b0000000, 13'b0);

    check_alu_immediate("addi", 3'b000, 7'b0000000, 4'd0);
    check_alu_immediate("slli", 3'b001, 7'b0000000, 4'd7);
    check_alu_immediate("slti", 3'b010, 7'b0000000, 4'd5);
    check_alu_immediate("sltiu", 3'b011, 7'b0000000, 4'd6);
    check_alu_immediate("xori", 3'b100, 7'b0000000, 4'd4);
    check_alu_immediate("srli", 3'b101, 7'b0000000, 4'd8);
    check_alu_immediate("srai", 3'b101, 7'b0100000, 4'd9);
    check_alu_immediate("ori", 3'b110, 7'b0000000, 4'd3);
    check_alu_immediate("andi", 3'b111, 7'b0000000, 4'd2);
    check("invalid immediate shift", 7'b0010011, 3'b001, 7'b0100000,
          {3'b000, 2'b00, 3'b001, 1'b0, 4'd0});

    check_alu_register("add", 3'b000, 7'b0000000, 4'd0);
    check_alu_register("sub", 3'b000, 7'b0100000, 4'd1);
    check_alu_register("sll", 3'b001, 7'b0000000, 4'd7);
    check_alu_register("slt", 3'b010, 7'b0000000, 4'd5);
    check_alu_register("sltu", 3'b011, 7'b0000000, 4'd6);
    check_alu_register("xor", 3'b100, 7'b0000000, 4'd4);
    check_alu_register("srl", 3'b101, 7'b0000000, 4'd8);
    check_alu_register("sra", 3'b101, 7'b0100000, 4'd9);
    check_alu_register("or", 3'b110, 7'b0000000, 4'd3);
    check_alu_register("and", 3'b111, 7'b0000000, 4'd2);
    check("m extension rejected", 7'b0110011, 3'b000, 7'b0000001, 13'b0);

    check("fence", 7'b0001111, 3'b000, 7'b0000000, 13'b0);
    check("system", 7'b1110011, 3'b000, 7'b0000000, 13'b0);
    check("unknown opcode", 7'b0000000, 3'b000, 7'b0000000, 13'b0);
  end
endmodule
