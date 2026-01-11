`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Two-stage synchronizer for the OR-of-rows (prevents metastability).
// -----------------------------------------------------------------------------
module synchronizer(
  input  [3:0] row,
  input        clock,
  input        reset,
  output reg   s_row
);
  reg sync0, sync1;
  wire row_or = |row; // reduction OR

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      sync0 <= 1'b0;
      sync1 <= 1'b0;
      s_row <= 1'b0;
    end else begin
      sync0 <= row_or;
      sync1 <= sync0;
      s_row <= sync1;
    end
  end
endmodule