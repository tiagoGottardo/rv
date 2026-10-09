module dcu (
    input  wire [31:0] inst,
    output wire [ 6:0] opcode,
    output reg         branch,
    output reg  [ 1:0] result_mux,
    output reg  [ 2:0] branch_op,
    output reg         mem_write,
    output reg         alu_src_a,
    output reg         alu_src_b,
    output reg         reg_write,
    output reg  [ 5:0] alu_op,
    output wire [31:0] rs1_addr,
    output wire [31:0] rs2_addr,
    output wire [31:0] rd_addr
);

endmodule
