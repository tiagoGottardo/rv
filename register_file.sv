module register_file (
    input  logic        clk,
    input  logic        write_enable,
    input  logic [ 4:0] ra1,
    input  logic [ 4:0] ra2,
    input  logic [ 4:0] debug_addr,
    input  logic [ 4:0] wa,
    input  logic [31:0] write_data,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] debug_data
);
  logic [31:0] regs[0:31];

  assign rd1 = (ra1 == 0) ? 32'b0 : regs[ra1];
  assign rd2 = (ra2 == 0) ? 32'b0 : regs[ra2];
  assign debug_data = (debug_addr == 0) ? 32'b0 : regs[debug_addr];

  always_ff @(posedge clk) begin
    if (write_enable && wa != 0) begin
      regs[wa] <= write_data;
    end
  end

endmodule
