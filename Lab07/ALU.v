`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

    always @(*) begin
        case (ALUCtrl)
            `AND:   BusW = BusA & BusB;
            `OR:    BusW = BusA | BusB;
            `ADD:   BusW = BusA + BusB;
            `SUB:   BusW = BusA - BusB; // This is 0110
            `PassB: BusW = BusB;

            // --- FIX: Handle SUB opcode (0011) from control unit ---
            4'b0011: BusW = BusA - BusB;
            // --- End of Fix ---

            default: BusW = 64'b0;
        endcase
    end

    assign Zero = (BusW == 64'b0);
endmodule
