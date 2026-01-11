
// =====================
// 2) Datapath
//    - Parameter N=8 (bits of operands)
//    - A width = N+1 to hold sign/extra bit
//    - Combined shift width = (N+1) + N + 1 = 18 bits (for N=8)
//    - Inputs: load, do_add (1=>add,0=>sub) done_add (capture ALU result),
//              do_shift (perform arithmetic right shift)
//    - Outputs: A_out (N+1 bits visible), Q_out, qm1_out, eqz (counter==0)
// =====================
module booth_datapath #(
  parameter N = 8
)(
  input  wire              clk,
  input  wire              rst,            // synchronous reset
  input  wire              load,           // load M and Q from switches
  input  wire              do_add,         // select add (1) or sub (0)
  input  wire              do_add_valid,   // capture ALU result into A
  input  wire              do_shift,       // perform arithmetic right shift
  input  wire [15:0]       switches,       // SW[15:8]=M, SW[7:0]=Q
  output wire [N:0]        A_out,          // A (N+1 bits)
  output wire [N-1:0]      Q_out,          // Q (N bits)
  output wire              qm1_out,        // Q-1 bit
  output wire              eqz             // counter == 0
);
  localparam AW = N + 1;
  reg [AW-1:0] A;      // N+1 bits
  reg [N-1:0]   Q;
  reg [AW-1:0]  M;     // sign-extended multiplicand
  reg           qm1;
  reg [3:0]     count; // enough to count to N (8 -> needs 4 bits)

  // ALU (combinational) - operate on N+1 bits
  wire [AW-1:0] alu_add  = A + M;
  wire [AW-1:0] alu_sub  = A - M;
  wire [AW-1:0] alu_res  = do_add ? alu_add : alu_sub;

  // combined temp for shifting: width = (N+1) + N + 1 = 2N + 2
  // For N=8 this is 18 bits (index 17 downto 0)
  reg [ (AW + N) : 0 ] combined; // width = AW+N+1

  // outputs
  assign A_out   = A;
  assign Q_out   = Q;
  assign qm1_out = qm1;
  assign eqz     = (count == 0);

  // synchronous datapath
  always @(posedge clk) begin
    if (rst) begin
      A <= {AW{1'b0}};
      Q <= {N{1'b0}};
      M <= {AW{1'b0}};
      qm1 <= 1'b0;
      count <= N;    // default to N cycles
      combined <= {(AW+N+1){1'b0}};
    end else begin
      if (load) begin
        // Load M (sign-extend), Q, clear A and qm1, reset counter
        M <= { switches[15], switches[15:8] }; // sign-extension into N+1 bits
        Q <= switches[7:0];
        A <= {AW{1'b0}};
        qm1 <= 1'b0;
        count <= N;
      end else begin
        // 1) Capture ALU result into A when controller requests
        if (do_add_valid) begin
          A <= alu_res;
        end

        // 2) Shift operation: do arithmetic right shift on {A, Q, qm1}
        if (do_shift) begin
          // build combined vector
          combined = { A, Q, qm1 };              // width AW+N+1
          // arithmetic right shift by 1: new MSB = old MSB (combined[top])
          combined = { combined[AW+N], combined[AW+N:1] };
          // unpack back to registers
          A   <= combined[AW+N : N+1];   // top AW bits
          Q   <= combined[N : 1];        // middle N bits
          qm1 <= combined[0];            // LSB
          // decrement counter (if not zero already)
          if (count != 0) count <= count - 1'b1;
        end
      end
    end
  end
endmodule
