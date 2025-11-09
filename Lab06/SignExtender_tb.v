// This is the updated SignExtender_tb.v
`timescale 1ns/1ps

// Re-define these from your file
`define IType   2'b00
`define DType   2'b01
`define CBType  2'b10
`define BType   2'b11

module SignExtender_tb;

    // --- Inputs are 'reg' (the robot's "hands") ---
    reg [25:0]  Instruction_tb;
    reg [1:0]   SignOp_tb;

    // --- Outputs are 'wire' (the robot's "eyes") ---
    wire [63:0] SignExOut_tb;

    // --- Instantiate the Unit Under Test (UUT) ---
    SignExtender uut (
        .Instruction(Instruction_tb),
        .SignOp(SignOp_tb),
        .SignExOut(SignExOut_tb)
    );

    // --- Simulation Code (the robot's checklist) ---
    initial begin
        // 1. Setup VCD waveform dump (the "video recorder")
        $dumpfile("signext_test.vcd");
        $dumpvars(0, uut);

        // 2. Define test cases
        $display("--- Starting Sign Extender Test (Corrected) ---");

        // Test 1: BType, positive offset (10 * 4 = 40 = 0x28)
        #10 SignOp_tb = `BType;
            Instruction_tb = 26'h000000A; // 10
        #10 $display("Op: %b, Inst: %h, Out: %h", SignOp_tb, Instruction_tb, SignExOut_tb);

        // Test 2: BType, negative offset (-10 * 4 = -40 = 0xFF...FE8)
        #10 SignOp_tb = `BType;
            Instruction_tb = 26'h3FFFFF6; // -10
        #10 $display("Op: %b, Inst: %h, Out: %h", SignOp_tb, Instruction_tb, SignExOut_tb);

        // Test 3: IType, ZERO-extended (now a positive number)
        #10 SignOp_tb = `IType;
            Instruction_tb = 26'h0200000; // Value at [21:10] is 0x800
        #10 $display("Op: %b, Inst: %h, Out: %h", SignOp_tb, Instruction_tb, SignExOut_tb);

        // Test 4: DType, SIGN-extended (no shift)
        #10 SignOp_tb = `DType;
            Instruction_tb = 26'h0100000; // Value at [20:12] is 0x100
        #10 $display("Op: %b, Inst: %h, Out: %h", SignOp_tb, Instruction_tb, SignExOut_tb);
     // Test 5: CBType, SIGN-extended (with shift)
        #10 SignOp_tb = `CBType;
            Instruction_tb = 26'h0800000; // Value at [23:5] is 0x800 (-ve)
        #10 $display("Op: %b, Inst: %h, Out: %h", SignOp_tb, Instruction_tb, SignExOut_tb);

        // 3. End simulation
        #10 $display("--- Test Complete ---");
        $finish;
    end

endmodule

