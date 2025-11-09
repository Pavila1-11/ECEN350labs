`define Itype   2'b00  // These defines are not required but may be helpful.
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp
);
 // This combinational 'always' block acts as the machine's "brain".
    // It re-runs instantly if 'Instruction' or 'SignOp' changes.
    always @(*) begin

        // This 'case' statement reads the 'SignOp' dial
        // and runs the *one* correct block of code.
        case (SignOp)

            // IType: ZERO-extends the 12-bit immediate [21:10].
            // Pads with 52 '0's.
            `IType: begin
                SignExOut = {52'b0, Instruction[21:10]};
            end

            // DType: SIGN-extends the 9-bit immediate [20:12].
            // Copies the "mood bit" [20] 55 times.
            `DType: begin
                SignExOut = {{55{Instruction[20]}}, Instruction[20:12]};
            end

            // CBType: SIGN-extends the 19-bit immediate [23:5] AND shifts left by 2.
            // Copies "mood bit" [23] 43 times and adds '00' at the end.
            `CBType: begin
                SignExOut = {{43{Instruction[23]}}, Instruction[23:5], 2'b00};
            end

            // BType: SIGN-extends the 26-bit immediate [25:0] AND shifts left by 2.
            // Copies "mood bit" [25] 36 times and adds '00' at the end.
            `BType: begin
                SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};
            end

            // A 'default' case is required to prevent "latches" (bad memory).
            // If 'SignOp' is unknown ('x'), the output will be 0.
            default: begin
                SignExOut = 64'b0;
            end

        endcase
    end
endmodule

