`timescale 1ns/1ps

module tb_NextPClogic;
    // --- Testbench Signal Declarations ---
    // 'reg' for inputs we will drive from the testbench.
    reg  [63:0] tb_CurrentPC;
    reg  [63:0] tb_SignExtImm64;
    reg         tb_Branch;
    reg         tb_ALUZero;
    reg         tb_Uncondbranch;
    // 'wire' for the output from the DUT (Design Under Test).
    wire [63:0] tb_NextPC;

    // --- Instantiate the NextPClogic Module (DUT) ---
    NextPClogic dut (
        .NextPC(tb_NextPC),
        .CurrentPC(tb_CurrentPC),
        .SignExtImm64(tb_SignExtImm64),
        .Branch(tb_Branch),
        .ALUZero(tb_ALUZero),
        .Uncondbranch(tb_Uncondbranch)
    );

    // --- Testbench Automation Variables ---
    integer i, j, k, test_num; // Loop counters
    integer error_count = 0;   // Tally of failed tests
    reg [63:0] expected_pc;   // Stores the correct value for comparison

    // --- VCD Waveform Dump Setup ---
    // This initial block runs once at the beginning of the simulation.
    initial begin
        $dumpfile("tb_NextPClogic.vcd"); // Name the output waveform file
        $dumpvars(0, tb_NextPClogic);    // Specify which signals to dump (0 means all)
    end

    // --- Main Test Sequence ---
    // This initial block contains the core logic for testing the DUT.
    initial begin
        $display("--- Starting NextPClogic Testbench ---");
        // Use three nested loops to test all 8 combinations of the control inputs.
        for (i = 0; i < 2; i = i + 1) begin      // Loop for tb_Branch (0, 1)
            for (j = 0; j < 2; j = j + 1) begin  // Loop for tb_ALUZero (0, 1)
                for (k = 0; k < 2; k = k + 1) begin // Loop for tb_Uncondbranch (0, 1)
                    tb_Branch = i;
                    tb_ALUZero = j;
                    tb_Uncondbranch = k;

                // For each control combination, run 10 tests with random data.
                    for (test_num = 0; test_num < 10; test_num = test_num + 1) begin
                        tb_CurrentPC = $random;
                        tb_SignExtImm64 = $random;

                        // Calculate the expected result based on the DUT's logic.
                        if ((tb_Branch & tb_ALUZero) | tb_Uncondbranch) begin
                            expected_pc = tb_CurrentPC + tb_SignExtImm64; // Branch is taken
                        end else begin
                            expected_pc = tb_CurrentPC + 4; // No branch, proceed sequentially
                        end

                        #10; // Wait 10ns for the DUT's combinational logic to settle.
                        // Self-checking: Compare the DUT's output to the expected value.
                        if (tb_NextPC !== expected_pc) begin
                            $display("ERROR: B=%b, Z=%b, U=%b", tb_Branch, tb_ALUZero, tb_Uncondbranch);
                            $display("  -> Inputs: PC=%h, Imm=%h", tb_CurrentPC, tb_SignExtImm64);
                            $display("  -> Expected: %h, Got: %h", expected_pc, tb_NextPC);
                            error_count = error_count + 1;
                        end
                    end
                end
            end
        end
        // --- Final Summary ---
        #10; // Final wait before finishing
        if (error_count == 0) begin
            $display("--- All 80 NextPClogic tests passed successfully! ---");
        end else begin
            $display("--- NextPClogic tests finished with %d errors. ---", error_count);
        end

        $finish; // End the simulation
    end
endmodule

