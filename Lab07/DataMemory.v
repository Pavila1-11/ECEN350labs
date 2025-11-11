`timescale 1ns / 1ps

`define SIZE 1024

module DataMemory(ReadData , Address , WriteData , MemoryRead , MemoryWrite , Clock);
   input [63:0]      WriteData;
   input [63:0]      Address;
   input             Clock, MemoryRead, MemoryWrite;
   output reg [63:0] ReadData;
   reg [7:0]         memBank [`SIZE-1:0];

   // Task to initialize memory
   task initset;
      input [63:0] addr;
      input [63:0] data;
      begin
         memBank[addr]   = data[63:56];
         memBank[addr+1] = data[55:48];
         memBank[addr+2] = data[47:40];
         memBank[addr+3] = data[39:32];
         memBank[addr+4] = data[31:24];
         memBank[addr+5] = data[23:16];
         memBank[addr+6] = data[15:8];
         memBank[addr+7] = data[7:0];
      end
   endtask

   // Initialize memory with test data
   initial
     begin
        // --- FIX: Initialize all memory to 0 ---
        integer i;
        for (i = 0; i < `SIZE; i = i + 1) begin
            memBank[i] = 8'b0;
        end
        // --- End of Fix ---

        initset( 64'h0,  64'h1);
        initset( 64'h8,  64'ha);
        initset( 64'h10, 64'h5);
        initset( 64'h18, 64'h0ffbea7deadbeeff);
        initset( 64'h20, 64'h0);
     end
 // --- FIX: Read logic MUST be combinational for single-cycle ---
   // Was: always @(posedge Clock)
   always @(*)
     begin
        if(MemoryRead)
          begin
             ReadData[63:56] = memBank[Address];
             ReadData[55:48] = memBank[Address+1];
             ReadData[47:40] = memBank[Address+2];
             ReadData[39:32] = memBank[Address+3];
             ReadData[31:24] = memBank[Address+4];
             ReadData[23:16] = memBank[Address+5];
             ReadData[15:8]  = memBank[Address+6];
             ReadData[7:0]   = memBank[Address+7];
          end
        else begin
             ReadData = 64'b0; // Prevent latches
        end
     end
   // --- End of Fix ---

   // Write logic MUST remain clocked
   always @(posedge Clock)
     begin
        if(MemoryWrite)
          begin
             memBank[Address]   <= #3 WriteData[63:56];
             memBank[Address+1] <= #3 WriteData[55:48];
             memBank[Address+2] <= #3 WriteData[47:40];
             memBank[Address+3] <= #3 WriteData[39:32];
             memBank[Address+4] <= #3 WriteData[31:24];
             memBank[Address+5] <= #3 WriteData[23:16];
             memBank[Address+6] <= #3 WriteData[15:8];
             memBank[Address+7] <= #3 WriteData[7:0];
          end
     end
endmodule


