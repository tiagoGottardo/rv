module branch_unit (
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [2:0] funct3,
    output reg branch
);

  always_comb begin
    case (funct3)
      3'd0: branch = (rs1 == rs2);
      3'd1: branch = (rs1 != rs2);
      3'd4: branch = ($signed(rs1) < $signed(rs2));
      3'd5: branch = ($signed(rs1) >= $signed(rs2));
      3'd6: branch = (rs1 < rs2);
      3'd7: branch = (rs1 >= rs2);
      default: branch = 1'b0;
    endcase
  end

endmodule
