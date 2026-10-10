module test_data_memory;
  logic        clk = 0;
  logic        write_enable;
  logic [ 2:0] funct3;
  logic [31:0] addr;
  logic [31:0] write_data;
  logic [31:0] read_data;
  logic        misaligned;

  data_memory #(
      .ADDR_WIDTH(2)
  ) dut (.*);

  always #5 clk = ~clk;

  task automatic store(input [2:0] operation, input [31:0] address, input [31:0] data);
    funct3      = operation;
    addr        = address;
    write_data  = data;
    write_enable = 1'b1;
    @(posedge clk);
    #1;
    write_enable = 1'b0;
  endtask

  task automatic load(input string name, input [2:0] operation, input [31:0] address,
                      input [31:0] expected);
    funct3 = operation;
    addr    = address;
    #1;
    if (read_data !== expected)
      $fatal(1, "%s: got %h, expected %h", name, read_data, expected);
  endtask

  initial begin
    write_enable = 1'b0;
    funct3 = 3'b010;
    addr = 32'b0;
    write_data = 32'b0;

    store(3'b010, 32'h0, 32'h80ff7f01);
    load("lw", 3'b010, 32'h0, 32'h80ff7f01);
    load("lb positive", 3'b000, 32'h0, 32'h00000001);
    load("lb negative", 3'b000, 32'h2, 32'hffffffff);
    load("lbu", 3'b100, 32'h3, 32'h00000080);
    load("lh positive", 3'b001, 32'h0, 32'h00007f01);
    load("lh negative", 3'b001, 32'h2, 32'hffff80ff);
    load("lhu", 3'b101, 32'h2, 32'h000080ff);

    store(3'b000, 32'h1, 32'h000000aa);
    load("sb lane", 3'b010, 32'h0, 32'h80ffaa01);
    store(3'b001, 32'h2, 32'h00001234);
    load("sh lane", 3'b010, 32'h0, 32'h1234aa01);

    funct3 = 3'b010;
    addr = 32'h1;
    #1;
    if (!misaligned || read_data !== 32'b0) $fatal(1, "misaligned word load accepted");

    store(3'b001, 32'h1, 32'h0000ffff);
    load("misaligned store suppressed", 3'b010, 32'h0, 32'h1234aa01);
    $finish(0);
  end
endmodule
