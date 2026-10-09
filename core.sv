module core #(
    parameter ADDR_WIDTH = 6,
    parameter INIT_FILE = ""
) (
    input wire clk,
    input wire rst
);
  wire [31:0] inst;
  wire [ 6:0] opcode;
  wire [ 4:0] rd_addr;
  wire [ 4:0] rs1_addr;
  wire [ 4:0] rs2_addr;
  wire [ 2:0] funct3;
  wire [ 6:0] funct7;

  wire        branch;
  wire        jump;
  wire        jump_register;
  wire [ 1:0] result_mux;
  wire        mem_write;
  wire        alu_src_a;
  wire        alu_src_b;
  wire        reg_write;
  wire [ 3:0] alu_op;

  wire [31:0] rs1_data;
  wire [31:0] rs2_data;
  wire [31:0] write_data;
  wire        rf_write_enable;
  wire [31:0] immediate_extended;
  wire [31:0] alu_a;
  wire [31:0] alu_b;
  wire [31:0] alu_result;
  wire        alu_zero;
  wire        branch_taken;

  wire [31:0] pc_current;
  wire [31:0] pc_plus_4;
  wire [31:0] branch_target;
  wire [31:0] jalr_target;
  reg  [31:0] pc_next;

  wire [31:0] data_read;
  wire        data_misaligned;

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
      .write_enable(rf_write_enable),
      .ra1(rs1_addr),
      .ra2(rs2_addr),
      .wa(rd_addr),
      .write_data(write_data),
      .rd1(rs1_data),
      .rd2(rs2_data)
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
      .enable(1'b1),
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
      .write_enable(mem_write),
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
