module hex7seg (
    input  wire [3:0] value,
    output reg  [6:0] segments_n
);
  always_comb begin
    case (value)
      4'h0: segments_n = 7'b1000000;
      4'h1: segments_n = 7'b1111001;
      4'h2: segments_n = 7'b0100100;
      4'h3: segments_n = 7'b0110000;
      4'h4: segments_n = 7'b0011001;
      4'h5: segments_n = 7'b0010010;
      4'h6: segments_n = 7'b0000010;
      4'h7: segments_n = 7'b1111000;
      4'h8: segments_n = 7'b0000000;
      4'h9: segments_n = 7'b0010000;
      4'ha: segments_n = 7'b0001000;
      4'hb: segments_n = 7'b0000011;
      4'hc: segments_n = 7'b1000110;
      4'hd: segments_n = 7'b0100001;
      4'he: segments_n = 7'b0000110;
      4'hf: segments_n = 7'b0001110;
      default: segments_n = 7'b1111111;
    endcase
  end
endmodule
