module core #(
    parameter ADDR_WIDTH = 6,
    parameter INIT_FILE = ""
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [ 4:0] debug_addr,
    output logic [31:0] debug_data
);
  logic [31:0] inst;
  logic [ 6:0] opcode;
  logic [ 4:0] rd_addr;
  logic [ 4:0] rs1_addr;
  logic [ 4:0] rs2_addr;
  logic [ 2:0] funct3;
  logic [ 6:0] funct7;

  logic        branch;
  logic        jump;
  logic        jump_register;
  logic [ 1:0] result_mux;
  logic        mem_write;
  logic        alu_src_a;
  logic        alu_src_b;
  logic        reg_write;
  logic [ 3:0] alu_op;

  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] write_data;
  logic        rf_write_enable;
  logic [31:0] immediate_extended;
  logic [31:0] alu_a;
  logic [31:0] alu_b;
  logic [31:0] alu_result;
  logic        alu_zero;
  logic        branch_taken;

  logic [31:0] pc_current;
  logic [31:0] pc_plus_4;
  logic [31:0] branch_target;
  logic [31:0] jalr_target;
  logic [31:0] pc_next;

  logic [31:0] data_read;
  logic        data_misaligned;

  inst_splitter inst_splitter (
      .inst(inst),
      .opcode(opcode),
      .rd(rd_addr),
      .rs1(rs1_addr),
      .rs2(rs2_addr),
      .funct3(funct3),
      .funct7(funct7)
  );

  dcu control (
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),
      .branch(branch),
      .jump(jump),
      .jump_register(jump_register),
      .result_mux(result_mux),
      .mem_write(mem_write),
      .alu_src_a(alu_src_a),
      .alu_src_b(alu_src_b),
      .reg_write(reg_write),
      .alu_op(alu_op)
  );

  register_file register_file (
      .clk(clk),
      .write_enable(rf_write_enable && enable),
      .ra1(rs1_addr),
      .ra2(rs2_addr),
      .debug_addr(debug_addr),
      .wa(rd_addr),
      .write_data(write_data),
      .rd1(rs1_data),
      .rd2(rs2_data),
      .debug_data(debug_data)
  );

  branch_unit branch_unit (
      .rs1(rs1_data),
      .rs2(rs2_data),
      .branch(branch),
      .funct3(funct3),
      .taken(branch_taken)
  );

  sign_extender sign_extender (
      .inst(inst),
      .opcode(opcode),
      .imm(immediate_extended)
  );

  mux2 alu_a_mux (
      .a(rs1_data),
      .b(pc_current),
      .sel(alu_src_a),
      .y(alu_a)
  );

  mux2 alu_b_mux (
      .a(rs2_data),
      .b(immediate_extended),
      .sel(alu_src_b),
      .y(alu_b)
  );

  alu alu (
      .a(alu_a),
      .b(alu_b),
      .op(alu_op),
      .result(alu_result),
      .zero(alu_zero)
  );

  plus4 pc_incrementer (
      .a(pc_current),
      .y(pc_plus_4)
  );

  assign branch_target = pc_current + immediate_extended;
  assign jalr_target = alu_result & 32'hfffffffe;

  always_comb begin
    if (jump_register) pc_next = jalr_target;
    else if (jump || branch_taken) pc_next = branch_target;
    else pc_next = pc_plus_4;
  end

  pc pc (
      .clk(clk),
      .reset(rst),
      .enable(enable),
      .next(pc_next),
      .current(pc_current)
  );

  inst_memory #(
      .INIT_FILE(INIT_FILE),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) inst_memory (
      .addr(pc_current),
      .inst(inst)
  );

  data_memory #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) data_memory (
      .clk(clk),
      .write_enable(mem_write && enable),
      .funct3(funct3),
      .addr(alu_result),
      .write_data(rs2_data),
      .read_data(data_read),
      .misaligned(data_misaligned)
  );

  assign rf_write_enable = reg_write && !((result_mux == 2'b01) && data_misaligned);

  mux4 writeback_mux (
      .a(alu_result),
      .b(data_read),
      .c(pc_plus_4),
      .d(immediate_extended),
      .sel(result_mux),
      .y(write_data)
  );
endmodule
