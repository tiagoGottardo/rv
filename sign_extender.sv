module sign_extender (
    input  wire [31:0] inst,
    input  wire [ 6:0] opcode,
    output reg  [31:0] imm
);

  // I Type
  `define OP_JALR 7'b1100111
  `define OP_LOAD 7'b0000011
  `define OP_ALUI 7'b0010011

  // S Type
  `define OP_STORE 7'b0100011

  // B Type
  `define OP_BRANCH 7'b1100011

  // U Type
  `define OP_LUI 7'b0110111
  `define OP_AUIPC 7'b0010111

  // J Type
  `define OP_JAL 7'b1101111

  always_comb begin
    case (opcode)
      OP_JALR, OP_LOAD, OP_ALUI: imm = {{20{inst[31]}}, inst[31:25], inst[24:21], inst[20]};  // I
      OP_STORE: imm = {{20{inst[31]}}, inst[31:25], inst[11:8], inst[7]};  // S
      OP_BRANCH: imm = {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};  // B
      OP_LUI, OP_AUIPC: imm = {inst[31], inst[30:20], inst[19:12], 12'b0};  // U
      OP_JAL: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};  // J
      default: imm = 32'hFFFF_FFFF;
    endcase
  end

endmodule

