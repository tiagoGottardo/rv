module tb_inst_memory;
  logic [31:0] addr;
  logic [31:0] inst;

  inst_memory #(
      .INIT_FILE("testbenches/fixtures/inst_memory.hex"),
      .ADDR_WIDTH(2)
  ) dut (
      .addr(addr),
      .inst(inst)
  );

  task automatic check(input [31:0] address, input [31:0] expected);
    addr = address;
    #1;
    if (inst !== expected) $fatal(1, "address %h: got %h, expected %h", address, inst, expected);
  endtask

  initial begin
    check(32'h00000000, 32'h00000013);
    check(32'h00000004, 32'h00100093);
    check(32'h00000008, 32'h00200113);
    check(32'h0000000c, 32'h00000000);
  end
endmodule
