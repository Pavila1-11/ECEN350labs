`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,      // The 64-bit result of the operation
    input      [63:0] BusA,      // First 64-bit operand
    input      [63:0] BusB,      // Second 64-bit operand
    input      [3:0]  ALUCtrl,   // 4-bit control signal for the operation
    output            Zero       // 1-bit flag, high when BusW is zero
);

    // This combinational block executes whenever any input (BusA, BusB, or ALUCtrl) changes.
    // We use always @(*) for combinational logic to ensure no unintended latches.
    always @(*) begin
        // The case statement selects which operation to perform based on ALUCtrl.
        case (ALUCtrl)
            `AND:   BusW = BusA & BusB; // Bitwise AND
            `OR:    BusW = BusA | BusB; // Bitwise OR
            `ADD:   BusW = BusA + BusB; // 64-bit Addition
            `SUB:   BusW = BusA - BusB; // 64-bit Subtraction
            `PassB: BusW = BusB;        // Pass BusB directly to the output

            // Default case assigns a known value (0) to prevent latches
            default: BusW = 64'b0;
        endcase
    end

    // Continuous assignment to the Zero flag.
    // 'Zero' is set to 1 if all 64 bits of BusW are 0.
    assign Zero = (BusW == 64'b0);

endmodule
