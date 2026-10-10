module sign_extender (
    input  logic [31:0] inst,
    input  logic [ 6:0] opcode,
    output logic [31:0] imm
);

  localparam [6:0] OP_JALR = 7'b1100111;
  localparam [6:0] OP_LOAD = 7'b0000011;
  localparam [6:0] OP_ALUI = 7'b0010011;
  localparam [6:0] OP_STORE = 7'b0100011;
  localparam [6:0] OP_BRANCH = 7'b1100011;
  localparam [6:0] OP_LUI = 7'b0110111;
  localparam [6:0] OP_AUIPC = 7'b0010111;
  localparam [6:0] OP_JAL = 7'b1101111;

  always @(*) begin
    case (opcode)
      OP_JALR, OP_LOAD, OP_ALUI: imm = {{20{inst[31]}}, inst[31:20]};
      OP_STORE: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
      OP_BRANCH: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      OP_LUI, OP_AUIPC: imm = {inst[31:12], 12'b0};
      OP_JAL: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      default: imm = 32'b0;
    endcase
  end

endmodule

