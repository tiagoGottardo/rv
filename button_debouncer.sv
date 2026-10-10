module button_debouncer #(
    parameter COUNTER_WIDTH = 20
) (
    input  logic clk,
    input  logic reset,
    input  logic button_n,
    output logic pressed_pulse
);
  logic button_meta_n;
  logic button_sync_n;
  logic debounced_n;
  logic [COUNTER_WIDTH-1:0] stability_counter;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      button_meta_n     <= 1'b1;
      button_sync_n     <= 1'b1;
      debounced_n       <= 1'b1;
      stability_counter <= {COUNTER_WIDTH{1'b0}};
      pressed_pulse     <= 1'b0;
    end else begin
      button_meta_n <= button_n;
      button_sync_n <= button_meta_n;
      pressed_pulse <= 1'b0;

      if (button_sync_n == debounced_n) begin
        stability_counter <= {COUNTER_WIDTH{1'b0}};
      end else if (&stability_counter) begin
        debounced_n       <= button_sync_n;
        stability_counter <= {COUNTER_WIDTH{1'b0}};
        if (!button_sync_n) pressed_pulse <= 1'b1;
      end else begin
        stability_counter <= stability_counter + 1'b1;
      end
    end
  end
endmodule
