module branch_unit (
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire        branch,
    input  wire [ 2:0] funct3,
    output reg         taken
);

  always_comb begin
    taken = 0;
    if (branch) begin
      case (funct3)
        3'd0: taken = (rs1 == rs2);
        3'd1: taken = (rs1 != rs2);
        3'd4: taken = ($signed(rs1) < $signed(rs2));
        3'd5: taken = ($signed(rs1) >= $signed(rs2));
        3'd6: taken = (rs1 < rs2);
        3'd7: taken = (rs1 >= rs2);
        default: taken = 1'b0;
      endcase
    end
  end

endmodule
