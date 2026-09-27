module inst_memory (
    input  wire [31:0] addr,
    output wire [31:0] inst
);
  reg [31:0] mem[0:255];

  assign inst = mem[addr[9:2]];
endmodule
