module dcu (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        branch,
    output reg        jump,
    output reg        jump_register,
    output reg  [1:0] result_mux,
    output reg        mem_write,
    output reg        alu_src_a,
    output reg        alu_src_b,
    output reg        reg_write,
    output reg  [3:0] alu_op
);
  // Instruction decoding is intentionally left for a separate implementation.
endmodule
