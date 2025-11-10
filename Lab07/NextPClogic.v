module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);
// This is the "brain" of the module.
    // It's always watching the inputs to decide the next PC address.
    always @(*) begin

        // --- Check for an Unconditional Branch ---
        // If 'Uncondbranch' is 1, we *always* take the branch.
        if (Uncondbranch == 1) begin
            NextPC = CurrentPC + SignExtImm64;

        // --- Check for a Conditional Branch ---
        // Else, if 'Branch' is 1 (we *might* branch)
        // AND 'ALUZero' is 1 (the condition is *true*)...
        end else if (Branch == 1 && ALUZero == 1) begin
            NextPC = CurrentPC + SignExtImm64; // ...then we take the branch.

        // --- No Branch (Default Case) ---
        // If neither branch is taken, just go to the next instruction.
        end else begin
            NextPC = CurrentPC + 4; // PC + 4
        end

    end

endmodule


