// =====================
// 1) Debounce module
//    - Inputs: btn_n (active-low physical button)
//    - Output: btn_tick (one-clock-cycle pulse when button is pressed)
// =====================
module debounce (
  input  wire clk,
  input  wire btn_n,       // active-low button
  output reg  btn_tick
);
  reg [15:0] cnt;
  reg sync0, sync1, stable;

  always @(posedge clk) begin
    sync0 <= ~btn_n;      // invert (btn_n is active-low) and sync
    sync1 <= sync0;
    if (sync1 != stable) begin
      cnt <= cnt + 1;
      if (cnt == 16'hFFFF) begin
        // commit new stable value and emit a one-cycle tick on rising
        btn_tick <= sync1 & ~stable;
        stable <= sync1;
        cnt <= 0;
      end else begin
        btn_tick <= 1'b0;
      end
    end else begin
      cnt <= 0;
      btn_tick <= 1'b0;
    end
  end
endmodule
