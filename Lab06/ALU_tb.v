// Testbench for the 64-bit ALU module (ALU.v)

// Time scale definition for simulation
`timescale 1ns / 1ps

// These defines MUST match those used in the ALU module
`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU_tb;

    // --- Signals for the Testbench (Wires and Regs) ---
    // Inputs to the ALU (defined as 'reg' because we drive them)
    reg  [63:0] BusA;
    reg  [63:0] BusB;
    reg  [3:0]  ALUCtrl;

    // Outputs from the ALU (defined as 'wire' because the module drives them)
    wire [63:0] BusW;
    wire        Zero;

    // --- Instantiate the Device Under Test (DUT) ---
    // The name 'dut' stands for Device Under Test
    ALU dut (
        .BusW(BusW),
        .BusA(BusA),
        .BusB(BusB),
        .ALUCtrl(ALUCtrl),
        .Zero(Zero)
    );

    // --- VCD Dump Setup (For GTKWave) ---
    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb); // Dump all signals in the current module scope
    end
 // --- Test Logic (Apply Stimulus) ---
    initial begin
        // Initialize inputs
        BusA    = 64'b0;
        BusB    = 64'b0;
        ALUCtrl = 4'b0;

        $display("------------------------------------------------------------------");
        $display("Starting ALU Testbench Simulation at time %0t", $time);
        $display("------------------------------------------------------------------");

        #10; // Wait 10ns for initialization stabilization

        // =====================================================================
        // 1. Test AND Operation (`AND = 4'b0000`)
        // =====================================================================
        ALUCtrl = `AND;
        BusA = 64'hFFFF0000FFFF0000;
        BusB = 64'h0000FFFF0000FFFF;
        #10;
        // Expected: BusW = 64'h0000000000000000 (Result is all zeros)
        $display("TEST 1 (AND): A=%h, B=%h. W=%h, Zero=%b (Expected W=0, Z=1)", BusA, BusB, BusW, Zero);
        if (BusW === 64'h0 && Zero === 1'b1) $display("-> PASS: AND with Zero output correct.");
        else $display("-> *** FAIL ***: AND result or Zero flag incorrect.");

        // =====================================================================
        // 2. Test OR Operation (`OR = 4'b0001`)
        // =====================================================================
        ALUCtrl = `OR;
        BusA = 64'hAAAAAAAABBBBAAAA;
        BusB = 64'h5555555544445555;
        #10;
        // Expected: BusW = 64'hFFFFFFFFFFFFFFFF
        $display("TEST 2 (OR): A=%h, B=%h. W=%h, Zero=%b (Expected W=all F, Z=0)", BusA, BusB, BusW, Zero);
        if (BusW === 64'hFFFFFFFFFFFFFFFF && Zero === 1'b0) $display("-> PASS: OR operation correct.");
        else $display("-> *** FAIL ***: OR result or Zero flag incorrect.");

        // =====================================================================
        // 3. Test ADD Operation (`ADD = 4'b0010`)
        // =====================================================================
        // Case 3a: Simple addition
        ALUCtrl = `ADD;
        BusA = 64'd100;
        BusB = 64'd50;
        #10;
 // Expected: BusW = 64'd150
        $display("TEST 3a (ADD): A=%d, B=%d. W=%d, Zero=%b (Expected W=150, Z=0)", BusA, BusB, BusW, Zero);
        if (BusW === 64'd150 && Zero === 1'b0) $display("-> PASS: Simple ADD correct.");
        else $display("-> *** FAIL ***: Simple ADD result incorrect.");

        // Case 3b: Addition resulting in Zero (Overflow/Wrap-around)
        BusA = 64'hFFFFFFFFFFFFFFFF; // Max 64-bit unsigned number
        BusB = 64'd1;
        #10;
        // Expected: BusW = 64'h0000000000000000 (due to 64-bit wrap-around)
        $display("TEST 3b (ADD): Overflow A=%h, B=%d. W=%h, Zero=%b (Expected W=0, Z=1)", BusA, BusB, BusW, Ze>
        if (BusW === 64'h0 && Zero === 1'b1) $display("-> PASS: ADD with Overflow/Zero output correct.");
        else $display("-> *** FAIL ***: ADD Overflow/Zero flag incorrect.");

        // =====================================================================
        // 4. Test SUB Operation (`SUB = 4'b0110`)
        // =====================================================================
        // Case 4a: Simple subtraction
        ALUCtrl = `SUB;
        BusA = 64'd200;
        BusB = 64'd75;
        #10;
        // Expected: BusW = 64'd125
        $display("TEST 4a (SUB): A=%d, B=%d. W=%d, Zero=%b (Expected W=125, Z=0)", BusA, BusB, BusW, Zero);
        if (BusW === 64'd125 && Zero === 1'b0) $display("-> PASS: Simple SUB correct.");
        else $display("-> *** FAIL ***: Simple SUB result incorrect.");

        // Case 4b: Subtraction resulting in Zero
        BusA = 64'hC0FFEE00DEADBEEF;
        BusB = 64'hC0FFEE00DEADBEEF;
        #10;
        // Expected: BusW = 64'h0000000000000000
        $display("TEST 4b (SUB): A=B Subtraction. W=%h, Zero=%b (Expected W=0, Z=1)", BusW, Zero);
        if (BusW === 64'h0 && Zero === 1'b1) $display("-> PASS: SUB with Zero output correct.");
        else $display("-> *** FAIL ***: SUB Zero flag incorrect.");

        // Case 4c: Subtraction resulting in Underflow (Large negative result)
        ALUCtrl = `SUB;
        BusA = 64'd10;
        BusB = 64'd100;
        #10;
        // Expected: BusW = 64'hFFFFFFFFFFFFA6 (2's complement of -90)
        $display("TEST 4c (SUB): Underflow (10-100). W=%h, Zero=%b (Expected W=...A6, Z=0)", BusW, Zero);

        // **FIXED CHECK:** Use Verilog's own calculation of the result for robust comparison.
        if (BusW === (64'd10 - 64'd100) && Zero === 1'b0) $display("-> PASS: SUB Underflow result correct (2's>
        else $display("-> *** FAIL ***: SUB Underflow result incorrect. Check W and Zero.");

// =====================================================================
        // 5. Test Pass B Operation (`PassB = 4'b0111`)
        // =====================================================================
        ALUCtrl = `PassB;
        BusA = 64'hDEADBEEFDEADBEEF; // A is irrelevant
        BusB = 64'h1122334455667788;
        #10;
        // Expected: BusW = BusB
        $display("TEST 5 (PassB): B=%h. W=%h, Zero=%b (Expected W=B, Z=0)", BusB, BusW, Zero);
        if (BusW === BusB && Zero === 1'b0) $display("-> PASS: PassB operation correct.");
        else $display("-> *** FAIL ***: PassB result or Zero flag incorrect.");

        // Case 5b: Pass B where B is zero
        BusB = 64'h0;
        #10;
        // Expected: BusW = 0, Zero = 1
        $display("TEST 5b (PassB): B=0. W=%h, Zero=%b (Expected W=0, Z=1)", BusW, Zero);
        if (BusW === 64'h0 && Zero === 1'b1) $display("-> PASS: PassB with Zero output correct.");
        else $display("-> *** FAIL ***: PassB Zero flag incorrect.");

        // =====================================================================
        // 6. Test Default Case (Unused control code)
        // =====================================================================
        ALUCtrl = 4'b1111; // A control code not covered in the defines
        BusA = 64'h1;
        BusB = 64'h1;
        #10;
        // Expected: BusW = 64'h0000000000000000 (from the 'default' case in ALU.v)
        $display("TEST 6 (DEFAULT): ALUCtrl=1111. W=%h, Zero=%b (Expected W=0, Z=1)", BusW, Zero);
        if (BusW === 64'h0 && Zero === 1'b1) $display("-> PASS: Default case correct (BusW=0, Zero=1).");
        else $display("-> *** FAIL ***: Default case logic incorrect.");


        $display("------------------------------------------------------------------");
        $display("ALU Testbench Simulation Finished at time %0t", $time);
        $display("------------------------------------------------------------------");

        $finish; // End the simulation
    end

endmodule
