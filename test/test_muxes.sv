module test_muxes;
  logic [31:0] a;
  logic [31:0] b;
  logic [31:0] c;
  logic [31:0] d;
  logic        sel2;
  logic [ 1:0] sel4;
  logic [31:0] y2;
  logic [31:0] y4;

  mux2 two_way (
      .a(a),
      .b(b),
      .sel(sel2),
      .y(y2)
  );

  mux4 four_way (
      .a(a),
      .b(b),
      .c(c),
      .d(d),
      .sel(sel4),
      .y(y4)
  );

  initial begin
    a = 32'ha;
    b = 32'hb;
    c = 32'hc;
    d = 32'hd;

    sel2 = 1'b0;
    #1;
    if (y2 !== a) $fatal(1, "mux2 input a not selected");
    sel2 = 1'b1;
    #1;
    if (y2 !== b) $fatal(1, "mux2 input b not selected");

    for (integer i = 0; i < 4; i = i + 1) begin
      sel4 = i[1:0];
      #1;
      case (i)
        0: if (y4 !== a) $fatal(1, "mux4 input a not selected");
        1: if (y4 !== b) $fatal(1, "mux4 input b not selected");
        2: if (y4 !== c) $fatal(1, "mux4 input c not selected");
        3: if (y4 !== d) $fatal(1, "mux4 input d not selected");
      endcase
    end
  end
endmodule
