module pc (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    input  logic [31:0] next,
    output logic [31:0] current
);
  always @(posedge clk or posedge reset) begin
    if (reset) current <= 0;
    else if (enable) current <= next;
  end
endmodule
