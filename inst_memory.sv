module inst_memory #(
    INIT_FILE  = "",
    ADDR_WIDTH = 8
) (
    input  wire [31:0] addr,
    output wire [31:0] inst
);
  parameter WORDS = (1 << ADDR_WIDTH);

  reg [31:0] mem[0:WORDS-1];

  initial begin
    if (INIT_FILE != "") begin
      for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'h0;
      $readmemh(INIT_FILE, mem);
    end
  end

  assign inst = mem[addr[ADDR_WIDTH+1:2]];
endmodule
