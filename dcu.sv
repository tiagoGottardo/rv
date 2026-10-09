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
  localparam [6:0] OP_LOAD = 7'b0000011;
  localparam [6:0] OP_MISC_MEM = 7'b0001111;
  localparam [6:0] OP_ALU_IMMEDIATE = 7'b0010011;
  localparam [6:0] OP_AUIPC = 7'b0010111;
  localparam [6:0] OP_STORE = 7'b0100011;
  localparam [6:0] OP_ALU_REGISTER = 7'b0110011;
  localparam [6:0] OP_LUI = 7'b0110111;
  localparam [6:0] OP_BRANCH = 7'b1100011;
  localparam [6:0] OP_JALR = 7'b1100111;
  localparam [6:0] OP_JAL = 7'b1101111;
  localparam [6:0] OP_SYSTEM = 7'b1110011;

  localparam [3:0] ALU_ADD = 4'd0;
  localparam [3:0] ALU_SUB = 4'd1;
  localparam [3:0] ALU_AND = 4'd2;
  localparam [3:0] ALU_OR = 4'd3;
  localparam [3:0] ALU_XOR = 4'd4;
  localparam [3:0] ALU_SLT = 4'd5;
  localparam [3:0] ALU_SLTU = 4'd6;
  localparam [3:0] ALU_SLL = 4'd7;
  localparam [3:0] ALU_SRL = 4'd8;
  localparam [3:0] ALU_SRA = 4'd9;

  localparam [1:0] RESULT_ALU = 2'b00;
  localparam [1:0] RESULT_MEMORY = 2'b01;
  localparam [1:0] RESULT_PC_PLUS_4 = 2'b10;
  localparam [1:0] RESULT_IMMEDIATE = 2'b11;

  always_comb begin
    branch = 1'b0;
    jump = 1'b0;
    jump_register = 1'b0;
    result_mux = RESULT_ALU;
    mem_write = 1'b0;
    alu_src_a = 1'b0;
    alu_src_b = 1'b0;
    reg_write = 1'b0;
    alu_op = ALU_ADD;

    case (opcode)
      OP_LUI: begin
        result_mux = RESULT_IMMEDIATE;
        reg_write  = 1'b1;
      end

      OP_AUIPC: begin
        alu_src_a = 1'b1;
        alu_src_b = 1'b1;
        reg_write = 1'b1;
      end

      OP_JAL: begin
        jump       = 1'b1;
        result_mux = RESULT_PC_PLUS_4;
        reg_write  = 1'b1;
      end

      OP_JALR: begin
        if (funct3 == 3'b000) begin
          jump_register = 1'b1;
          result_mux    = RESULT_PC_PLUS_4;
          alu_src_b     = 1'b1;
          reg_write     = 1'b1;
        end
      end

      OP_BRANCH: begin
        case (funct3)
          3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: branch = 1'b1;
          default: branch = 1'b0;
        endcase
      end

      OP_LOAD: begin
        case (funct3)
          3'b000, 3'b001, 3'b010, 3'b100, 3'b101: begin
            result_mux = RESULT_MEMORY;
            alu_src_b  = 1'b1;
            reg_write  = 1'b1;
          end
          default: ;
        endcase
      end

      OP_STORE: begin
        case (funct3)
          3'b000, 3'b001, 3'b010: begin
            mem_write = 1'b1;
            alu_src_b = 1'b1;
          end
          default: ;
        endcase
      end

      OP_ALU_IMMEDIATE: begin
        alu_src_b = 1'b1;
        case (funct3)
          3'b000: begin
            alu_op    = ALU_ADD;
            reg_write = 1'b1;
          end
          3'b001: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SLL;
              reg_write = 1'b1;
            end
          end
          3'b010: begin
            alu_op    = ALU_SLT;
            reg_write = 1'b1;
          end
          3'b011: begin
            alu_op    = ALU_SLTU;
            reg_write = 1'b1;
          end
          3'b100: begin
            alu_op    = ALU_XOR;
            reg_write = 1'b1;
          end
          3'b101: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SRL;
              reg_write = 1'b1;
            end else if (funct7 == 7'b0100000) begin
              alu_op    = ALU_SRA;
              reg_write = 1'b1;
            end
          end
          3'b110: begin
            alu_op    = ALU_OR;
            reg_write = 1'b1;
          end
          3'b111: begin
            alu_op    = ALU_AND;
            reg_write = 1'b1;
          end
          default: ;
        endcase
      end

      OP_ALU_REGISTER: begin
        case (funct3)
          3'b000: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_ADD;
              reg_write = 1'b1;
            end else if (funct7 == 7'b0100000) begin
              alu_op    = ALU_SUB;
              reg_write = 1'b1;
            end
          end
          3'b001: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SLL;
              reg_write = 1'b1;
            end
          end
          3'b010: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SLT;
              reg_write = 1'b1;
            end
          end
          3'b011: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SLTU;
              reg_write = 1'b1;
            end
          end
          3'b100: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_XOR;
              reg_write = 1'b1;
            end
          end
          3'b101: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_SRL;
              reg_write = 1'b1;
            end else if (funct7 == 7'b0100000) begin
              alu_op    = ALU_SRA;
              reg_write = 1'b1;
            end
          end
          3'b110: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_OR;
              reg_write = 1'b1;
            end
          end
          3'b111: begin
            if (funct7 == 7'b0000000) begin
              alu_op    = ALU_AND;
              reg_write = 1'b1;
            end
          end
          default: ;
        endcase
      end

      OP_MISC_MEM, OP_SYSTEM: ;

      default: ;
    endcase
  end
endmodule
