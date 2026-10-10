module tb_fibonacci_program;
  logic clk = 0;
  logic rst = 0;
  logic enable = 1;
  logic [4:0] debug_addr = 0;
  logic [31:0] debug_data;

  core #(
      .ADDR_WIDTH(6),
      .INIT_FILE("program.hex")
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .debug_addr(debug_addr),
      .debug_data(debug_data)
  );

  always #1 clk = ~clk;

  initial begin
    #1 rst = 1'b1;
    #1 rst = 1'b0;
    repeat (55) @(posedge clk);
    #1;

    if (dut.register_file.regs[1] !== 32'd55)
      $fatal(1, "fibonacci x1: got %0d", dut.register_file.regs[1]);
    if (dut.register_file.regs[2] !== 32'd89)
      $fatal(1, "fibonacci x2: got %0d", dut.register_file.regs[2]);
    if (dut.register_file.regs[3] !== 32'd0)
      $fatal(1, "fibonacci counter: got %0d", dut.register_file.regs[3]);
    if (dut.pc_current !== 32'd32)
      $fatal(1, "fibonacci halt loop pc: got %0d", dut.pc_current);

    $finish(0);
  end
endmodule
