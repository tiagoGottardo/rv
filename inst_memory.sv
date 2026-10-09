module inst_memory #(
    INIT_FILE  = "",
    ADDR_WIDTH = 8
) (
    input  wire [31:0] addr,
    output wire [31:0] inst
);
  parameter WORDS = (1 << ADDR_WIDTH);

  reg [31:0] mem[0:WORDS-1];
  integer i;

  initial begin
    for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'b0;
    if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
  end

  assign inst = mem[addr[ADDR_WIDTH+1:2]];
endmodule
