module test_core_program;
  logic clk = 0;
  logic rst = 0;
  logic enable = 1;
  logic [4:0] debug_addr = 0;
  logic [31:0] debug_data;

  core #(
      .ADDR_WIDTH(4),
      .INIT_FILE("test/fixtures/core_program.hex")
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .debug_addr(debug_addr),
      .debug_data(debug_data)
  );

  always #5 clk = ~clk;

  task automatic check_register(input [4:0] address, input [31:0] expected);
    if (dut.register_file.regs[address] !== expected)
      $fatal(1, "x%0d: got %h, expected %h", address, dut.register_file.regs[address], expected);
  endtask

  initial begin
    #1 rst = 1'b1;
    #1 rst = 1'b0;

    repeat (12) @(posedge clk);
    #1;

    check_register(5'd1, 32'd5);
    check_register(5'd2, 32'd7);
    check_register(5'd3, 32'd12);
    check_register(5'd4, 32'd12);
    check_register(5'd5, 32'h12345000);
    check_register(5'd6, 32'd36);
    check_register(5'd7, 32'd1);
    check_register(5'd8, 32'd40);

    if (dut.data_memory.mem[0] !== 32'd12)
      $fatal(1, "stored word: got %h, expected %h", dut.data_memory.mem[0], 32'd12);
    if (dut.pc_current !== 32'd44)
      $fatal(1, "pc after program: got %h, expected %h", dut.pc_current, 32'd44);

    $finish(0);
  end
endmodule
