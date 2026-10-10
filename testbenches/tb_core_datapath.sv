module tb_core_datapath;
  logic clk = 0;
  logic rst = 0;
  logic enable = 1;
  logic [4:0] debug_addr = 0;
  logic [31:0] debug_data;

  core #(
      .ADDR_WIDTH(2)
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .debug_addr(debug_addr),
      .debug_data(debug_data)
  );

  always #5 clk = ~clk;

  initial begin
    force dut.branch = 1'b0;
    force dut.jump = 1'b0;
    force dut.jump_register = 1'b0;
    force dut.result_mux = 2'b00;
    force dut.mem_write = 1'b0;
    force dut.alu_src_a = 1'b0;
    force dut.alu_src_b = 1'b0;
    force dut.reg_write = 1'b0;
    force dut.alu_op = 4'd0;

    #1 rst = 1'b1;
    #1;
    if (dut.pc_current !== 32'b0) $fatal(1, "reset pc: got %h", dut.pc_current);
    rst = 1'b0;

    @(posedge clk);
    #1;
    if (dut.pc_current !== 32'd4) $fatal(1, "sequential pc: got %h", dut.pc_current);

    enable = 1'b0;
    @(posedge clk);
    #1;
    if (dut.pc_current !== 32'd4) $fatal(1, "disabled pc changed: got %h", dut.pc_current);
    enable = 1'b1;

    force dut.immediate_extended = 32'd12;
    force dut.jump = 1'b1;
    @(posedge clk);
    #1;
    if (dut.pc_current !== 32'd16) $fatal(1, "jal target: got %h", dut.pc_current);

    force dut.jump = 1'b0;
    force dut.branch = 1'b1;
    force dut.rs1_data = 32'd5;
    force dut.rs2_data = 32'd5;
    force dut.immediate_extended = -32'sd4;
    @(posedge clk);
    #1;
    if (dut.pc_current !== 32'd12) $fatal(1, "branch target: got %h", dut.pc_current);

    force dut.branch = 1'b0;
    force dut.jump_register = 1'b1;
    force dut.alu_result = 32'h00000021;
    @(posedge clk);
    #1;
    if (dut.pc_current !== 32'h00000020) $fatal(1, "jalr target: got %h", dut.pc_current);

    force dut.jump_register = 1'b0;
    force dut.result_mux = 2'b01;
    force dut.reg_write = 1'b1;
    force dut.rd_addr = 5'd5;
    force dut.funct3 = 3'b010;
    force dut.alu_result = 32'h00000001;
    dut.register_file.regs[5] = 32'h12345678;
    @(posedge clk);
    #1;
    if (dut.register_file.regs[5] !== 32'h12345678)
      $fatal(1, "misaligned load changed destination register");

    $finish(0);
  end
endmodule
