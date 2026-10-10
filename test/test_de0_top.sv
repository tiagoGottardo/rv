module test_de0_top;
  logic       CLOCK_50 = 0;
  logic [1:0] BUTTON = 2'b11;
  logic [5:0] SW = 6'b0;
  logic [6:0] HEX0_D;
  logic [6:0] HEX1_D;
  logic [6:0] HEX2_D;
  logic [6:0] HEX3_D;
  logic       HEX0_DP;
  logic       HEX1_DP;
  logic       HEX2_DP;
  logic       HEX3_DP;

  de0_top #(
      .ADDR_WIDTH(2),
      .INIT_FILE(""),
      .DEBOUNCE_COUNTER_WIDTH(2)
  ) dut (.*);

  always #1 CLOCK_50 = ~CLOCK_50;

  initial begin
    BUTTON[1] = 1'b0;
    repeat (2) @(posedge CLOCK_50);
    BUTTON[1] = 1'b1;
    repeat (3) @(posedge CLOCK_50);

    BUTTON[0] = 1'b0;
    repeat (10) @(posedge CLOCK_50);
    #1;
    if (dut.cpu.pc_current !== 32'd4)
      $fatal(1, "first button press did not execute exactly one instruction");

    repeat (10) @(posedge CLOCK_50);
    #1;
    if (dut.cpu.pc_current !== 32'd4)
      $fatal(1, "held button executed more than one instruction");

    BUTTON[0] = 1'b1;
    repeat (9) @(posedge CLOCK_50);
    BUTTON[0] = 1'b0;
    repeat (9) @(posedge CLOCK_50);
    #1;
    if (dut.cpu.pc_current !== 32'd8)
      $fatal(1, "second button press did not execute the next instruction");

    dut.cpu.register_file.regs[3] = 32'hdeadbeef;
    SW[4:0] = 5'd3;
    SW[5] = 1'b0;
    #1;
    if ({HEX3_D, HEX2_D, HEX1_D, HEX0_D} !==
        {7'b0000011, 7'b0000110, 7'b0000110, 7'b0001110})
      $fatal(1, "lower half display is incorrect");

    SW[5] = 1'b1;
    #1;
    if ({HEX3_D, HEX2_D, HEX1_D, HEX0_D} !==
        {7'b0100001, 7'b0000110, 7'b0001000, 7'b0100001})
      $fatal(1, "upper half display is incorrect");

    SW[4:0] = 5'd0;
    #1;
    if ({HEX3_D, HEX2_D, HEX1_D, HEX0_D} !== {4{7'b1000000}})
      $fatal(1, "x0 display is incorrect");
    if ({HEX3_DP, HEX2_DP, HEX1_DP, HEX0_DP} !== 4'b1111)
      $fatal(1, "decimal points are not disabled");

    $finish(0);
  end
endmodule
