module test_button_debouncer;
  logic clk = 0;
  logic reset;
  logic button_n;
  logic pressed_pulse;
  integer pulse_count = 0;

  button_debouncer #(
      .COUNTER_WIDTH(2)
  ) dut (.*);

  always #1 clk = ~clk;
  always @(posedge clk) begin
    if (pressed_pulse) pulse_count <= pulse_count + 1;
  end

  initial begin
    reset = 1'b1;
    button_n = 1'b1;
    repeat (2) @(posedge clk);
    reset = 1'b0;

    button_n = 1'b0;
    repeat (2) @(posedge clk);
    button_n = 1'b1;
    repeat (5) @(posedge clk);
    if (pulse_count != 0) $fatal(1, "button bounce generated a pulse");

    button_n = 1'b0;
    repeat (9) @(posedge clk);
    if (pulse_count != 1) $fatal(1, "stable press generated %0d pulses", pulse_count);

    repeat (10) @(posedge clk);
    if (pulse_count != 1) $fatal(1, "held button repeated the pulse");

    button_n = 1'b1;
    repeat (9) @(posedge clk);
    button_n = 1'b0;
    repeat (9) @(posedge clk);
    if (pulse_count != 2) $fatal(1, "second press was not detected");

    $finish(0);
  end
endmodule
