
module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);
    always @(*) begin

        // --- Check for an Unconditional Branch ---
        if (Uncondbranch == 1) begin
            NextPC = CurrentPC + SignExtImm64;
        // --- Check for a Conditional Branch (if condition is true) ---
        end else if (Branch == 1 && ALUZero == 1) begin
            NextPC = CurrentPC + SignExtImm64;
        // --- No Branch (Default Case) ---
        end else begin
            NextPC = CurrentPC + 4; // PC + 4
        end
    end
endmodule





