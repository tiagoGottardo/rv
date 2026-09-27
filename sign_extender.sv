module sign_extender (
    input  wire [31:0] inst,
    input  wire [ 2:0] sel,
    output reg  [31:0] imm
);

  always_comb begin
    case (sel)
      3'd0: imm = {{20{inst[31]}}, inst[31:25], inst[24:21], inst[20]};
      3'd1: imm = {{20{inst[31]}}, inst[31:25], inst[11:8], inst[7]};
      3'd2: imm = {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
      3'd3: imm = {inst[31], inst[30:20], inst[19:12], 12'b0};
      3'd4: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
      default: imm = 0;
    endcase
  end

endmodule

