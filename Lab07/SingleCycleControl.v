`timescale 1ns/1ps

// Opcode encodings (with don't-care bits using ? for casez)
`define OPCODE_ANDREG  11'b10001010000  // AND
`define OPCODE_ORRREG  11'b10101010000  // ORR
`define OPCODE_ADDREG  11'b10001011000  // ADD
`define OPCODE_SUBREG  11'b11001011000  // SUB

`define OPCODE_ADDIMM  11'b1001000100?  // ADDI (I-type, low bit varies)
`define OPCODE_SUBIMM  11'b1101000100?  // SUBI (I-type)

`define OPCODE_MOVZ    11'b110100101??  // MOVZ (Move wide with zero)

`define OPCODE_B       11'b000101?????  // Unconditional branch
`define OPCODE_CBZ     11'b10110100???  // Conditional branch

`define OPCODE_LDUR    11'b11111000010  // Load
`define OPCODE_STUR    11'b11111000000  // Store

module SC_Control(
    output reg       Reg2Loc,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Uncondbranch,
    output reg [3:0] ALUOp,    // See localparam encodings below
    output reg [1:0] SignOp,   // See localparam encodings below
    input      [10:0] opcode
);
    // ALUOp encodings (Must match ALU.v)
    localparam [3:0] ALU_AND   = 4'b0000;
    localparam [3:0] ALU_ORR   = 4'b0001;
    localparam [3:0] ALU_ADD   = 4'b0010;
    localparam [3:0] ALU_SUB   = 4'b0011; // Note: ALU.v uses 0110 for SUB
    localparam [3:0] ALU_PASSB = 4'b0111; // BUGFIX: Was 4'b0100, now 4'b0111 to matc>

    // SignOp encodings (Must match SignExtender.v)
    localparam [1:0] SEXT_9     = 2'b00; // 9-bit signed (LDUR/STUR)
    localparam [1:0] SEXT_19    = 2'b01; // 19-bit signed (CBZ)
    localparam [1:0] SEXT_26    = 2'b10; // 26-bit signed (B)
    localparam [1:0] ZEXT_12_16 = 2'b11; // 12-bit (I-type) or 16-bit (MOVZ)
 // Default all-zero outputs for undefined opcodes
    always @* begin
        // Safe defaults (all zeros)
        Reg2Loc       = 1'b0;
        ALUSrc        = 1'b0;
        MemtoReg      = 1'b0;
        RegWrite      = 1'b0;
        MemRead       = 1'b0;
        MemWrite      = 1'b0;
        Branch        = 1'b0;
        Uncondbranch  = 1'b0;
        ALUOp         = ALU_AND; // Default to a safe op
        SignOp        = SEXT_9;  // Default to a safe op

        // Decode using casez to handle don't-care bits
        casez (opcode)

            // R-type
            `OPCODE_ANDREG: begin RegWrite=1; ALUOp=ALU_AND; SignOp=ZEXT_12_16; end
            `OPCODE_ORRREG: begin RegWrite=1; ALUOp=ALU_ORR; SignOp=ZEXT_12_16; end
            `OPCODE_ADDREG: begin RegWrite=1; ALUOp=ALU_ADD; SignOp=ZEXT_12_16; end
            `OPCODE_SUBREG: begin RegWrite=1; ALUOp=4'b0011; SignOp=ZEXT_12_16; end />

            // I-type
            `OPCODE_ADDIMM: begin ALUSrc=1; RegWrite=1; ALUOp=ALU_ADD; SignOp=ZEXT_12>
            `OPCODE_SUBIMM: begin ALUSrc=1; RegWrite=1; ALUOp=4'b0011; SignOp=ZEXT_12>

            // MOVZ
            `OPCODE_MOVZ:   begin ALUSrc=1; RegWrite=1; ALUOp=ALU_PASSB; SignOp=ZEXT_>

            // D-type
            `OPCODE_LDUR:   begin ALUSrc=1; MemtoReg=1; RegWrite=1; MemRead=1; ALUOp=>
            `OPCODE_STUR:   begin Reg2Loc=1; ALUSrc=1; MemWrite=1; ALUOp=ALU_ADD; Sig>

            // Branch
            `OPCODE_CBZ:    begin Branch=1; ALUOp=ALU_AND; SignOp=SEXT_19; end
            `OPCODE_B:      begin Uncondbranch=1; ALUOp=ALU_AND; SignOp=SEXT_26; end

            default: begin
                // All zeros already assigned by defaults
            end
        endcase
    end
endmodule


