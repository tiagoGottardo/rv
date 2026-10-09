module tb_register_file;
  logic        clk = 0;
  logic        write_enable;
  logic [ 4:0] ra1;
  logic [ 4:0] ra2;
  logic [ 4:0] wa;
  logic [31:0] write_data;
  logic [31:0] rd1;
  logic [31:0] rd2;

  register_file dut (.*);

  always #5 clk = ~clk;

  task automatic write(input [4:0] address, input [31:0] data);
    wa           = address;
    write_data   = data;
    write_enable = 1'b1;
    @(posedge clk);
    #1;
    write_enable = 1'b0;
  endtask

  initial begin
    write_enable = 1'b0;
    ra1 = 5'd0;
    ra2 = 5'd0;
    wa = 5'd0;
    write_data = 32'b0;

    write(5'd3, 32'h12345678);
    ra1 = 5'd3;
    #1;
    if (rd1 !== 32'h12345678) $fatal(1, "register write: got %h", rd1);

    write(5'd0, 32'hffffffff);
    ra2 = 5'd0;
    #1;
    if (rd2 !== 32'b0) $fatal(1, "x0 changed: got %h", rd2);

    $finish;
  end
endmodule
