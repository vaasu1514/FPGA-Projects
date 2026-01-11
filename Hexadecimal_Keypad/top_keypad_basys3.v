// -----------------------------------------------------------------------------
// Top-level for Basys-3 (no debounce).
// Connect:
//   - row_in[3:0]  -> keypad ROW0..ROW3 (inputs). Provide external 10k pull-downs or enable internal PDs.
//   - col_out[3:0] -> keypad COL0..COL3 (outputs).
//   - leds[3:0]    -> any four onboard LEDs to display code.
//   - led_valid    -> LED indicating raw 'valid' (no debounce).
// Port 'btnC' is used as reset (active-high).
// -----------------------------------------------------------------------------
module top_keypad_basys3_nodebounce(
  input        clk,        // board 100 MHz clock
  input        btnC,       // reset (use center push button)
  input  [3:0] row_in,     // ROW lines from keypad (hardware)
  output [3:0] col_out,    // COL lines to keypad (hardware)
  output [3:0] leds,       // simple visual: show 4-bit code on LEDs
  output       led_valid   // raw valid (no debounce)
);

  wire s_row;
  wire [3:0] code;
  wire valid;
  reg rst_d;

  // Simple reset synchronization (single flop)
  always @(posedge clk) rst_d <= btnC;
  wire reset_sync = rst_d;

  // synchronizer for row OR
  synchronizer u_sync(.row(row_in), .clock(clk), .reset(reset_sync), .s_row(s_row));

  // scanner (drives columns, reads rows)
  hex_keypad_scanner u_scan(.clock(clk), .reset(reset_sync), .row(row_in),
                            .s_row(s_row), .code(code), .valid(valid), .col(col_out));

  // outputs (no debounce): show code and raw valid
  assign leds = code;
  assign led_valid = valid;

endmodule