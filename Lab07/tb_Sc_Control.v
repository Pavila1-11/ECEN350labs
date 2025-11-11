`timescale 1ns/1ps

module tb_SC_Control;
    reg  [10:0] opcode;
    wire        Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch;
    wire [3:0]  ALUOp;
    wire [1:0]  SignOp;

    integer i, errors;

    // Instantiate DUT
    SC_Control dut(
        .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite),
        .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Uncondbranch(Uncondbranch),
        .ALUOp(ALUOp), .SignOp(SignOp), .opcode(opcode)
    );

    // Expected signals
    reg exp_Reg2Loc, exp_ALUSrc, exp_MemtoReg, exp_RegWrite, exp_MemRead, exp_MemWrite, exp_Branch, exp_Uncon>
    reg [3:0] exp_ALUOp;
    reg [1:0] exp_SignOp;

    // Encodings from SC_Control.v
    localparam [3:0] ALU_AND   = 4'b0000;
    localparam [3:0] ALU_ORR   = 4'b0001;
    localparam [3:0] ALU_ADD   = 4'b0010;
    localparam [3:0] ALU_SUB   = 4'b0011;
    localparam [3:0] ALU_PASSB = 4'b0111;
    localparam [1:0] SEXT_9     = 2'b00;
    localparam [1:0] SEXT_19    = 2'b01;
    localparam [1:0] SEXT_26    = 2'b10;
    localparam [1:0] ZEXT_12_16 = 2'b11;

    // Task to check outputs
    task check;
        input [8*20:1] name;
        begin
            #1; // Wait for combinational logic
            if (Reg2Loc      !== exp_Reg2Loc     || ALUSrc       !== exp_ALUSrc      ||
                MemtoReg     !== exp_MemtoReg    || RegWrite     !== exp_RegWrite    ||
                MemRead      !== exp_MemRead     || MemWrite     !== exp_MemWrite    ||
                Branch       !== exp_Branch      || Uncondbranch !== exp_Uncondbranch||
                ALUOp        !== exp_ALUOp       || SignOp       !== exp_SignOp) begin

                $display("ERROR: %s opcode=0x%h (%b)", name, opcode, opcode);
                $display("       got: R2L=%b ALS=%b M2R=%b RW=%b MR=%b MW=%b BR=%b UBR=%b ALU=%b SGN=%b",
                         Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch, ALUOp,>
                $display("       exp: R2L=%b ALS=%b M2R=%b RW=%b MR=%b MW=%b BR=%b UBR=%b ALU=%b SGN=%b",
                         exp_Reg2Loc, exp_ALUSrc, exp_MemtoReg, exp_RegWrite, exp_MemRead, exp_MemWrite, exp_>
                errors = errors + 1;
            end
        end
    endtask

    // Task to set expected values
    task set_expected;
        input eR2L, eALS, eM2R, eRW, eMR, eMW, eBR, eUBR;
        input [3:0] eALU;
        input [1:0] eSGN;
        begin
            exp_Reg2Loc = eR2L; exp_ALUSrc = eALS; exp_MemtoReg = eM2R; exp_RegWrite = eRW;
            exp_MemRead = eMR; exp_MemWrite = eMW; exp_Branch = eBR; exp_Uncondbranch = eUBR;
            exp_ALUOp = eALU; exp_SignOp = eSGN;
        end
    endtask

    // Default expected (for invalid opcodes)
    task set_default;
        begin
            set_expected(0,0,0,0,0,0,0,0, ALU_AND, SEXT_9); // Match defaults in SC_Control
        end
    endtask

    initial begin
        errors = 0;
        $dumpfile("sc_control.vcd");
        $dumpvars(0, tb_SC_Control);

        $display("Starting Exhaustive Control Unit Test...");

        // --- R-type ---
        set_expected(0,0,0,1,0,0,0,0, ALU_AND, ZEXT_12_16); opcode = 11'b10001010000; check("AND");
        set_expected(0,0,0,1,0,0,0,0, ALU_ORR, ZEXT_12_16); opcode = 11'b10101010000; check("ORR");
        set_expected(0,0,0,1,0,0,0,0, ALU_ADD, ZEXT_12_16); opcode = 11'b10001011000; check("ADD");
        set_expected(0,0,0,1,0,0,0,0, ALU_SUB, ZEXT_12_16); opcode = 11'b11001011000; check("SUB");

        // --- I-type ---
        set_expected(0,1,0,1,0,0,0,0, ALU_ADD, ZEXT_12_16);
        for (i = 0; i < 2; i = i + 1) begin opcode = {11'b1001000100, i[0]}; check("ADDI"); end
        set_expected(0,1,0,1,0,0,0,0, ALU_SUB, ZEXT_12_16);
        for (i = 0; i < 2; i = i + 1) begin opcode = {11'b1101000100, i[0]}; check("SUBI"); end

        // --- D-type ---
        set_expected(0,1,1,1,1,0,0,0, ALU_ADD, SEXT_9); opcode = 11'b11111000010; check("LDUR");
        set_expected(1,1,0,0,0,1,0,0, ALU_ADD, SEXT_9); opcode = 11'b11111000000; check("STUR");

        // --- Branch-type (Exhaustive) ---
        set_expected(0,0,0,0,0,0,0,1, ALU_AND, SEXT_26);
        for (i = 0; i < 32; i = i + 1) begin opcode = {11'b000101, i[4:0]}; check("B"); end
        set_expected(0,0,0,0,0,0,1,0, ALU_AND, SEXT_19);
        for (i = 0; i < 8; i = i + 1) begin opcode = {11'b10110100, i[2:0]}; check("CBZ"); end

        // --- MOVZ (Exhaustive) ---
        set_expected(0,1,0,1,0,0,0,0, ALU_PASSB, ZEXT_12_16);
        for (i = 0; i < 4; i = i + 1) begin opcode = {11'b110100101, i[1:0]}; check("MOVZ"); end
  // --- Invalid Opcodes ---
        set_default();
        opcode = 11'b00000000000; check("INVALID (all 0s)");
        opcode = 11'b11111111111; check("INVALID (all 1s)");

        if (errors == 0) $display("PASS: All control unit tests passed.");
        else $display("FAIL: %0d errors found.", errors);

        $finish;
    end
endmodule

