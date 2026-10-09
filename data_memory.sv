module data_memory #(
    parameter ADDR_WIDTH = 6
) (
    input  wire        clk,
    input  wire        write_enable,
    input  wire [ 2:0] funct3,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
  parameter WORDS = (1 << ADDR_WIDTH);

  reg [31:0] mem[0:WORDS-1];
  wire [7:0] word_addr;

  assign word_addr = addr[ADDR_WIDTH+1:2];
  assign read_data = mem[word_addr];

  always @(posedge clk) begin
    if (write_enable) begin
      case (funct3)
        0: begin
          case (addr[1:0])
            0: mem[word_addr][7:0] <= write_data[7:0];
            1: mem[word_addr][15:8] <= write_data[7:0];
            2: mem[word_addr][23:16] <= write_data[7:0];
            3: mem[word_addr][31:24] <= write_data[7:0];
          endcase
        end
        1: begin
          if (addr[1] == 0) mem[word_addr][15:0] <= write_data[15:0];
          else mem[word_addr][31:16] <= write_data[15:0];
        end
        2: begin
          mem[word_addr] <= write_data;
        end
        default: mem[word_addr] <= mem[word_addr];
      endcase
    end
  end
endmodule
