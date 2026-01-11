// =====================
// 3) Controller (FSM)
//    - Single-step event triggers a whole Booth iteration (add/sub if needed, then shift).
//    - States: IDLE -> READY -> DECIDE -> ADD/SUB -> SHIFT -> CHECK -> DONE
//    - Inputs: start_load (pulse), step_event (pulse), q0, qm1, eqz
//    - Outputs: load (pulse), do_add (select add/sub), do_add_valid (pulse), do_shift (pulse), done
// =====================
module booth_controller #(
  parameter N = 8
)(
  input  wire       clk,
  input  wire       rst,            // synchronous reset
  input  wire       start_load,     // pulse (BTN_C)
  input  wire       step_event,     // pulse (manual or auto)
  input  wire       q0,             // Q[0] from datapath
  input  wire       qm1,            // Q-1
  input  wire       eqz,            // counter == 0
  output reg        load,           // pulse to datapath to load operands
  output reg        do_add,         // 1->add, 0->sub (used when do_add_valid asserted)
  output reg        do_add_valid,   // capture ALU result into A
  output reg        do_shift,       // perform shift (one cycle)
  output reg        done
);
  // FSM states
  localparam IDLE   = 3'd0,
             READY  = 3'd1,
             DECIDE = 3'd2,
             ADD    = 3'd3,
             SUB    = 3'd4,
             SHIFT  = 3'd5,
             CHECK  = 3'd6,
             FIN    = 3'd7;

  reg [2:0] state, next_state;

  // state register
  always @(posedge clk) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end

  // next-state and outputs (combinational logic)
  always @(*) begin
    // default outputs
    load = 1'b0;
    do_add = 1'b1;
    do_add_valid = 1'b0;
    do_shift = 1'b0;
    done = 1'b0;
    next_state = state;

    case (state)
      IDLE: begin
        if (start_load) begin
          load = 1'b1;          // pulse to load datapath
          next_state = READY;
        end else next_state = IDLE;
      end

      READY: begin
        // If the counter already zero, go to FIN
        if (eqz) next_state = FIN;
        else if (step_event) next_state = DECIDE;
        else next_state = READY;
      end

      DECIDE: begin
        // decide based on (Q0, QM1)
        if ({q0, qm1} == 2'b01) begin
          next_state = ADD;
        end else if ({q0, qm1} == 2'b10) begin
          next_state = SUB;
        end else begin
          next_state = SHIFT;
        end
      end

      ADD: begin
        do_add = 1'b1;
        do_add_valid = 1'b1;   // one-cycle pulse to capture A = A + M
        next_state = SHIFT;
      end

      SUB: begin
        do_add = 1'b0;
        do_add_valid = 1'b1;   // one-cycle pulse to capture A = A - M
        next_state = SHIFT;
      end

      SHIFT: begin
        do_shift = 1'b1;       // one-cycle shift (datapath decrements counter)
        next_state = CHECK;
      end

      CHECK: begin
        // after shift, datapath updated count; check eqz
        if (eqz) next_state = FIN;
        else next_state = READY;
      end

      FIN: begin
        done = 1'b1;
        if (start_load) begin
          load = 1'b1;
          next_state = READY;
        end else next_state = FIN;
      end

      default: next_state = IDLE;
    endcase
  end
endmodule