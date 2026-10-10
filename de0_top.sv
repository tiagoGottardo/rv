module de0_top #(
    parameter ADDR_WIDTH = 6,
    parameter INIT_FILE = "programs/fibonacci.hex",  // init file path
    parameter DEBOUNCE_COUNTER_WIDTH = 20
) (
    input  logic       CLOCK_50,
    input  logic [1:0] BUTTON,
    input  logic [5:0] SW,
    output logic [6:0] HEX0_D,
    output logic [6:0] HEX1_D,
    output logic [6:0] HEX2_D,
    output logic [6:0] HEX3_D,
    output logic       HEX0_DP,
    output logic       HEX1_DP,
    output logic       HEX2_DP,
    output logic       HEX3_DP
);
  logic [1:0] reset_pipeline;

  logic        reset;
  logic        cpu_step;
  logic [31:0] selected_register;
  logic [15:0] displayed_half;

  initial reset_pipeline = 2'b11;

  always_ff @(posedge CLOCK_50 or negedge BUTTON[1]) begin
    if (!BUTTON[1]) reset_pipeline <= 2'b11;
    else reset_pipeline <= {reset_pipeline[0], 1'b0};
  end

  assign reset = reset_pipeline[1];
  assign displayed_half = SW[5] ? selected_register[31:16] : selected_register[15:0];
  assign HEX0_DP = 1'b1;
  assign HEX1_DP = 1'b1;
  assign HEX2_DP = 1'b1;
  assign HEX3_DP = 1'b1;

  button_debouncer #(
      .COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH)
  ) clock_button (
      .clk(CLOCK_50),
      .reset(reset),
      .button_n(BUTTON[0]),
      .pressed_pulse(cpu_step)
  );

  core #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .INIT_FILE (INIT_FILE)
  ) cpu (
      .clk(CLOCK_50),
      .rst(reset),
      .enable(cpu_step),
      .debug_addr(SW[4:0]),
      .debug_data(selected_register)
  );

  hex7seg hex0 (
      .value(displayed_half[3:0]),
      .segments_n(HEX0_D)
  );

  hex7seg hex1 (
      .value(displayed_half[7:4]),
      .segments_n(HEX1_D)
  );

  hex7seg hex2 (
      .value(displayed_half[11:8]),
      .segments_n(HEX2_D)
  );

  hex7seg hex3 (
      .value(displayed_half[15:12]),
      .segments_n(HEX3_D)
  );
endmodule
