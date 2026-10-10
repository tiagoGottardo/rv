module tb_fibonacci_program;
  logic clk = 0;
  logic rst = 0;
  logic enable = 1;
  logic [4:0] debug_addr = 0;
  logic [31:0] debug_data;

  core #(
      .ADDR_WIDTH(6),
      .INIT_FILE("programs/fibonacci.hex")
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
    repeat (65) @(posedge clk);
    #1;

    if (dut.register_file.regs[5] !== 32'd55)
      $fatal(1, "fibonacci t0: got %0d", dut.register_file.regs[5]);
    if (dut.register_file.regs[6] !== 32'd89)
      $fatal(1, "fibonacci t1: got %0d", dut.register_file.regs[6]);
    if (dut.register_file.regs[7] !== 32'd0)
      $fatal(1, "fibonacci counter: got %0d", dut.register_file.regs[7]);
    if (dut.data_memory.mem[0] !== 32'd55)
      $fatal(1, "stored fibonacci result: got %0d", dut.data_memory.mem[0]);
    if (dut.pc_current !== 32'd40)
      $fatal(1, "pc before ebreak: got %0d", dut.pc_current);

    $finish(0);
  end
endmodule
