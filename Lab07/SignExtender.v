`timescale 1ns/1ps

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction, // ARMv8 instruction bits [25:0]
    input      [1:0]  SignOp       // Control signal from SC_Control
);

    // SignOp encodings (Must match SingleCycleControl.v)
    localparam [1:0] SEXT_9     = 2'b00; // 9-bit signed (LDUR/STUR)
    localparam [1:0] SEXT_19    = 2'b01; // 19-bit signed (CBZ)
    localparam [1:0] SEXT_26    = 2'b10; // 26-bit signed (B)
    localparam [1:0] ZEXT_12_16 = 2'b11; // 12-bit (I-type) or 16-bit (MOVZ)

    // Partial opcodes (available in Instruction[25:0])
    localparam [4:0] OPCODE_MOVZ_PARTIAL = 5'b10101; // Opcode[25:21] for MOVZ

    // Internal wires for instruction fields
    wire [15:0] imm16; // MOVZ immediate [20:5]
    wire [1:0]  hw;    // MOVZ shift amount [22:21]
    wire [11:0] imm12; // I-type immediate [21:10]
    wire [8:0]  imm9;  // D-type immediate [20:12]
    wire [18:0] imm19; // CB-type immediate [23:5]
    wire [25:0] imm26; // B-type immediate [25:0]

    // Extract fields from the 26-bit instruction input
    assign imm16 = Instruction[20:5];
    assign hw    = Instruction[22:21];
    assign imm12 = Instruction[21:10];
    assign imm9  = Instruction[20:12];
    assign imm19 = Instruction[23:5];
    assign imm26 = Instruction[25:0];
always @(*) begin
        case (SignOp)

            // SEXT_9: 9-bit sign-extend (for LDUR/STUR)
            SEXT_9: begin
                SignExOut = {{55{imm9[8]}}, imm9};
            end

            // SEXT_19: 19-bit sign-extend, shift left 2 (for CBZ)
            SEXT_19: begin
                SignExOut = {{43{imm19[18]}}, imm19, 2'b00};
            end

            // SEXT_26: 26-bit sign-extend, shift left 2 (for B)
            SEXT_26: begin
                SignExOut = {{36{imm26[25]}}, imm26, 2'b00};
            end

            // ZEXT_12_16: 12-bit (I-type) or 16-bit (MOVZ)
            ZEXT_12_16: begin
                // This is the datapath addition for Part 3.
                // We check the partial opcode to see if this is MOVZ.
                if (Instruction[25:21] == OPCODE_MOVZ_PARTIAL) begin
                    // This is MOVZ. Build the 64-bit immediate based on shift.
                    case (hw)
                        2'b00: SignExOut = {48'b0, imm16};           // LSL 0
                        2'b01: SignExOut = {32'b0, imm16, 16'b0};  // LSL 16
                        2'b10: SignExOut = {16'b0, imm16, 32'b0};  // LSL 32
                        2'b11: SignExOut = {imm16, 48'b0};        // LSL 48
                    endcase
                end else begin
                    // This is I-type (ADDI/SUBI). 12-bit zero-extend.
                    SignExOut = {52'b0, imm12};
                end
            end

            // Default case to prevent latches
            default: begin
                SignExOut = 64'b0;
            end
        endcase
    end
endmodule
