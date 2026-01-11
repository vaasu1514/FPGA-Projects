// -----------------------------------------------------------------------------
// Hex keypad scanner: drives col_out (one-hot) and reads row.
// Produces 4-bit code and a combinational 'valid' while on the matching column.
// -----------------------------------------------------------------------------
module hex_keypad_scanner(
  input        clock,
  input        reset,
  input  [3:0] row,
  input        s_row,   // synchronized OR-of-rows used to start scanning
  output reg [3:0] code,
  output       valid,
  output reg [3:0] col
);
  reg [5:0] state, next_state;
  localparam S0 = 6'b000001;
  localparam S1 = 6'b000010;
  localparam S2 = 6'b000100;
  localparam S3 = 6'b001000;
  localparam S4 = 6'b010000;
  localparam S5 = 6'b100000;

  assign valid = ((state == S1) || (state == S2) || (state == S3) || (state == S4)) && (row != 4'b0000);

  always @* begin
    case ({row, col})
      8'b0001_0001 : code = 4'h0; // '1'
      8'b0001_0010 : code = 4'h1; // '2'
      8'b0001_0100 : code = 4'h2; // '3'
      8'b0001_1000 : code = 4'h3; // 'A'
      8'b0010_0001 : code = 4'h4; // '4'
      8'b0010_0010 : code = 4'h5; // '5'
      8'b0010_0100 : code = 4'h6; // '6'
      8'b0010_1000 : code = 4'h7; // 'B'
      8'b0100_0001 : code = 4'h8; // '7'
      8'b0100_0010 : code = 4'h9; // '8'
      8'b0100_0100 : code = 4'hA; // '9'
      8'b0100_1000 : code = 4'hB; // 'C'
      8'b1000_0001 : code = 4'hC; // '*'
      8'b1000_0010 : code = 4'hD; // '0'
      8'b1000_0100 : code = 4'hE; // '#'
      8'b1000_1000 : code = 4'hF; // 'D'
      default      : code = 4'h0;
    endcase
  end

  // state register
  always @(posedge clock or posedge reset) begin
    if (reset) state <= S0;
    else state <= next_state;
  end

  // next state and column driving
  always @* begin
    next_state = state;
    col = 4'b0000;
    case (state)
      S0: begin
        col = 4'b1111; // idle (no column driven)
        if (s_row) next_state = S1;
      end
      S1: begin
        col = 4'b0001;
        if (row != 4'b0000) next_state = S5;
        else next_state = S2;
      end
      S2: begin
        col = 4'b0010;
        if (row != 4'b0000) next_state = S5;
        else next_state = S3;
      end
      S3: begin
        col = 4'b0100;
        if (row != 4'b0000) next_state = S5;
        else next_state = S4;
      end
      S4: begin
        col = 4'b1000;
        if (row != 4'b0000) next_state = S5;
        else next_state = S0;
      end
      S5: begin
        col = 4'b1111; // found; wait for release
        if (row != 4'b0000) next_state = S5;
        else next_state = S0;
      end
      default: begin
        next_state = S0;
        col = 4'b1111;
      end
    endcase
  end
endmodule