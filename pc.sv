module pc (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [31:0] next,
    output reg [31:0] current
);
  always @(posedge clk) begin
    if (reset) current <= 0;
    else if (enable) current <= next;
  end
endmodule
