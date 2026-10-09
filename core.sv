module core (
    input wire clk,
    input wire rst
);
  parameter ADDR_WIDTH = 6;

  wire [31:0] inst;
  wire [ 6:0] opcode;
  wire        branch;
  wire [ 1:0] result_mux;
  wire [ 2:0] branch_op;
  wire        mem_write;
  wire        alu_src_a;
  wire        alu_src_b;
  wire        reg_write;
  wire [ 5:0] alu_op;
  wire [31:0] rs1_addr;
  wire [31:0] rs2_addr;
  wire [31:0] rd_addr;

  wire        rf_write_enable;
  wire [ 4:0] ra1;
  wire [ 4:0] ra2;
  wire [ 4:0] wa;
  wire [31:0] write_data;
  reg  [31:0] rd1;
  reg  [31:0] rd2;

  wire        taken;
  reg  [31:0] immediate_extend;
  reg  [31:0] alu_a;
  reg  [31:0] alu_b;
  reg  [31:0] alu_y;
  reg  [31:0] alu_plus_4;

  reg  [31:0] D;
  reg  [31:0] Q;


  dcu dcu (
      .inst(inst),
      .opcode(opcode),
      .branch(branch),
      .result_mux(result_mux),
      .branch_op(branch_op),
      .mem_write(mem_write),
      .alu_src_a(alu_src_a),
      .alu_src_b(alu_src_b),

      .reg_write(reg_write),
      .alu_op(alu_op),
      .rs1_addr(rs1_addr),
      .rs2_addr(rs2_addr),
      .rd_addr(rd_addr)
  );

  register_file register_file (
      .clk(clk),
      .write_enable(rf_write_enable),
      .ra1(ra1),
      .ra2(ra2),
      .wa(wa),
      .write_data(write_data),
      .rd1(rd1),
      .rd2(rd2)
  );

  branch_unit branch_unit (
      .a(rd1),
      .b(rd2),
      .branch(branch),
      .funct3(branch_op),
      .taken(taken)
  );

  sign_extender sign_extender (
      inst(inst),
      opcode(opcode),
      imm(immediate_extend)
  );

  mux_alu_a mux2 (
      a(rd1),
      b(Q),
      sel(alu_src_a),
      y(alu_a)
  );

  mux_alu_b mux2 (
      a(rd2),
      b(immediate_extend),
      sel(alu_src_b),
      y(alu_b)
  );

  alu alu (
      a(alu_a),
      b(alu_b),
      op(alu_op),
      result(alu_y)
  );

  assign alu_plus_4 = alu_y + 3'b100;

  mux_final mux2 (
      a(alu_plus_4),
      b(alu_y),
      sel(taken),
      y(D)
  );

  pc pc (
      clk(clk),
      reset(rst),
      enable(1),
      next(D),
      current(Q)
  );

  inst_memory #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .INIT_FILE ("bin.hex"),   // TODO: create programs to run.
  ) inst_memory (
      .addr(Q),
      .inst(inst)
  );

  data_memory #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) data_memory (
      .clk(clk),
      .we(mem_write_safe && cpu_enable),
      .funct3(funct3),
      .addr(alu_result),
      .write_data(rs2_data),
      .read_data(data_read),
  );

  reg mux4_sel = (result_mux == 2'b10) ? 2'b00 : (result_mux == 2'b01) ? 2'b01 : ~result_mux;

  mux4 mux4 (
      a(read_data),
      b(alu_plus_4),
      c(alu_y),
      d(0),
      sel(mux4_sel),
      y(write_data),
  );

endmodule
