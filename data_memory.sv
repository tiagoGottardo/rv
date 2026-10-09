module data_memory #(
    parameter ADDR_WIDTH = 6
) (
    input  wire        clk,
    input  wire        write_enable,
    input  wire [ 2:0] funct3,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data,
    output reg         misaligned
);
  parameter WORDS = (1 << ADDR_WIDTH);

  reg [31:0] mem[0:WORDS-1];
  wire [ADDR_WIDTH-1:0] word_addr;
  reg  [             7:0] selected_byte;
  reg  [            15:0] selected_half;

  assign word_addr = addr[ADDR_WIDTH+1:2];

  always_comb begin
    case (addr[1:0])
      2'd0: selected_byte = mem[word_addr][7:0];
      2'd1: selected_byte = mem[word_addr][15:8];
      2'd2: selected_byte = mem[word_addr][23:16];
      default: selected_byte = mem[word_addr][31:24];
    endcase

    selected_half = addr[1] ? mem[word_addr][31:16] : mem[word_addr][15:0];

    case (funct3)
      3'b000: read_data = {{24{selected_byte[7]}}, selected_byte};
      3'b001: read_data = {{16{selected_half[15]}}, selected_half};
      3'b010: read_data = mem[word_addr];
      3'b100: read_data = {24'b0, selected_byte};
      3'b101: read_data = {16'b0, selected_half};
      default: read_data = 32'b0;
    endcase

    case (funct3)
      3'b001, 3'b101: misaligned = addr[0];
      3'b010: misaligned = |addr[1:0];
      default: misaligned = 1'b0;
    endcase

    if (misaligned) read_data = 32'b0;
  end

  always @(posedge clk) begin
    if (write_enable && !misaligned) begin
      case (funct3)
        3'b000: begin
          case (addr[1:0])
            2'd0: mem[word_addr][7:0] <= write_data[7:0];
            2'd1: mem[word_addr][15:8] <= write_data[7:0];
            2'd2: mem[word_addr][23:16] <= write_data[7:0];
            default: mem[word_addr][31:24] <= write_data[7:0];
          endcase
        end
        3'b001: begin
          if (!addr[1]) mem[word_addr][15:0] <= write_data[15:0];
          else mem[word_addr][31:16] <= write_data[15:0];
        end
        3'b010: mem[word_addr] <= write_data;
        default: ;
      endcase
    end
  end
endmodule
