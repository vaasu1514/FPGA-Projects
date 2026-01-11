// -----------------------------------------------------------------------------
// Debounce for an input signal 'noisy'.
// COUNT_MAX should be set according to your clk frequency and desired debounce ms.
// For Basys-3 100 MHz and 5 ms: COUNT_MAX = 100_000_000 * 0.005 = 500_000
// -----------------------------------------------------------------------------
module debounce #(
  parameter integer COUNT_MAX = 500000
)(
  input  clk,
  input  rst,
  input  noisy,
  output reg clean
);
  reg [31:0] cnt;
  reg sync0, sync1;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sync0 <= 1'b0;
      sync1 <= 1'b0;
      cnt   <= 32'd0;
      clean <= 1'b0;
    end else begin
      // first synchronize the noisy signal
      sync0 <= noisy;
      sync1 <= sync0;

      if (sync1 == clean) begin
        cnt <= 32'd0;            // stable same as clean -> reset counter
      end else begin
        if (cnt >= COUNT_MAX) begin
          cnt <= 32'd0;
          clean <= sync1;        // accept new stable value
        end else begin
          cnt <= cnt + 1;
        end
      end
    end
  end
endmodule
