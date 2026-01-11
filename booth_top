// =====================
// 4) Top module
//    - Instantiates debounce, clock divider (for auto mode), controller & datapath
//    - Buttons on Basys-3 are active-low; pass them into debounce
// =====================
module booth_top (
  input  wire        clk,       // 100 MHz on Basys-3
  input  wire        btnC,      // center (active-low)
  input  wire        btnU,      // up
  input  wire        btnL,      // left (auto toggle)
  input  wire        btnR,      // right (reset)
  input  wire        btnD,      // down (unused)
  input  wire [15:0] sw,        // switches
  output wire [15:0] led        // LEDs
);
  // Debounced button pulses
  wire load_btn_tick, step_btn_tick, auto_btn_tick, rst_btn_tick;
  debounce db_load (.clk(clk), .btn_n(btnC), .btn_tick(load_btn_tick));
  debounce db_step (.clk(clk), .btn_n(btnU), .btn_tick(step_btn_tick));
  debounce db_auto (.clk(clk), .btn_n(btnL), .btn_tick(auto_btn_tick));
  debounce db_rst  (.clk(clk), .btn_n(btnR), .btn_tick(rst_btn_tick));

  // Auto-mode register (toggle on auto_btn_tick)
  reg auto_mode;
  always @(posedge clk) begin
    if (rst_btn_tick) auto_mode <= 1'b0;
    else if (auto_btn_tick) auto_mode <= ~auto_mode;
  end

  // Auto clock divider: ~6 Hz tick using 24-bit counter (100MHz / 2^24 ≈ 5.96 Hz)
  reg [23:0] auto_cnt;
  wire auto_tick = (auto_cnt == 24'd0);
  always @(posedge clk) begin
    if (rst_btn_tick) auto_cnt <= 24'd1;
    else auto_cnt <= auto_cnt + 1'b1;
  end

  // Create single-cycle step_event: manual button OR (auto_mode & auto_tick)
  wire step_event = step_btn_tick | (auto_mode & auto_tick);

  // Wires for datapath-controller
  wire [8:0] A_out;
  wire [7:0] Q_out;
  wire qm1;
  wire eqz;

  wire ctrl_load, ctrl_do_add, ctrl_do_add_valid, ctrl_do_shift, ctrl_done;

  // instantiate controller & datapath
  booth_controller #(8) ctrl (
    .clk(clk), .rst(rst_btn_tick),
    .start_load(load_btn_tick),
    .step_event(step_event),
    .q0(Q_out[0]), .qm1(qm1), .eqz(eqz),
    .load(ctrl_load),
    .do_add(ctrl_do_add),
    .do_add_valid(ctrl_do_add_valid),
    .do_shift(ctrl_do_shift),
    .done(ctrl_done)
  );

  booth_datapath #(8) dp (
    .clk(clk), .rst(rst_btn_tick),
    .load(ctrl_load),
    .do_add(ctrl_do_add),
    .do_add_valid(ctrl_do_add_valid),
    .do_shift(ctrl_do_shift),
    .switches(sw),
    .A_out(A_out),
    .Q_out(Q_out),
    .qm1_out(qm1),
    .eqz(eqz)
  );

  // Map outputs to LEDs:
  // Show A (lower 8 bits) on LED[15:8] and Q on LED[7:0]
  // A_out is 9 bits; we show A_out[7:0] on LEDs. If you want the 9th bit, use an external indicator.
  assign led[15:8] = A_out[7:0];
  assign led[7:0]  = Q_out;

  // (Optional) You may display "auto mode" or "done" using 7-seg displays or by changing LED mapping.
endmodule
