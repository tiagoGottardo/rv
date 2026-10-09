module register_file (
    input  wire        clk,
    input  wire        write_enable,
    input  wire [ 4:0] ra1,
    input  wire [ 4:0] ra2,
    input  wire [ 4:0] wa,
    input  wire [31:0] write_data,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
  reg [31:0] regs[0:31];

  assign rd1 = (ra1 == 0) ? 32'b0 : regs[ra1];
  assign rd2 = (ra2 == 0) ? 32'b0 : regs[ra2];

  always_ff @(posedge clk) begin
    if (write_enable && wa != 0) begin
      regs[wa] <= write_data;
    end
  end

endmodule
