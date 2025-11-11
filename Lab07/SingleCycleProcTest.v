`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module SingleCycleProcTest_v;
   initial
     begin
        $dumpfile("singlecycle.vcd");
        $dumpvars;
     end

   task passTest;
      input [63:0] actualOut, expectedOut;
      input [`STRLEN*8:0] testType;
      inout [7:0]         passed;
      if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = p>
      else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedO>
   endtask

   task allPassed;
      input [7:0] passed; input [7:0] numTests;
      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed: %d of %d passed", passed, numTests);
   endtask

   reg            CLK;
   reg            Reset;
   reg [63:0]     startPC;
   reg [7:0]      passed;
   reg [15:0]     watchdog;
   wire [63:0]    MemtoRegOut;
   wire [63:0]    currentPC;

   SingleCycleProc uut (
                    .CLK(CLK), .reset(Reset), .startpc(startPC),
                    .currentpc(currentPC), .MemtoRegOut(MemtoRegOut)
                    );

 initial begin
      Reset = 0; startPC = 0; passed = 0; watchdog = 0;
      #(1 * `ClockPeriod);

      // Program 1
      #1 Reset = 1; startPC = 0;
      @(posedge CLK); @(negedge CLK); @(posedge CLK);
      Reset = 0;

      // --- FIX: Changed < to <= to execute the last instruction ---
      while (currentPC <= 64'h30) // Was <
      // --- End of Fix ---
        begin
           @(posedge CLK); @(negedge CLK);
           $display("CurrentPC:%h",currentPC);
        end
      passTest(MemtoRegOut, 64'hF, "Results of Program 1", passed);

      // Test 2
      #1 Reset = 1; startPC = 64'h034;
      @(posedge CLK); @(negedge CLK); @(posedge CLK);
      Reset = 0;

      // --- FIX: Changed < to <= to execute the last instruction ---
      while (currentPC <= 64'h058) // Was <
      // --- End of Fix ---
        begin
           @(posedge CLK); @(negedge CLK);
           $display("CurrentPC:%h",currentPC);
        end
      passTest(MemtoRegOut, 64'h123456789ABCDEF0, "Results of Program 2 (MOVZ)", pass>

      allPassed(passed, 2);
      $finish;
   end

   initial begin CLK = 0; end
   always begin #`HalfClockPeriod CLK = ~CLK; watchdog = watchdog +1; end
   always @* if (watchdog == 16'hFFFF) begin $display("Watchdog Timer Expired."); $fi>
endmodule
