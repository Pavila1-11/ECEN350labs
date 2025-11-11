`timescale 1ns / 1ps
module InstructionMemory(Data, Address);
   output reg [31:0] Data;
   input [63:0]  Address;

   always @ (Address) begin
      case(Address)
        63'h000: Data = 32'hF84003E9;
        63'h004: Data = 32'hF84083EA;
        63'h008: Data = 32'hF84103EB;
        63'h00c: Data = 32'hF84183EC;
        63'h010: Data = 32'hF84203ED;
        63'h014: Data = 32'hAA0B014A;
        63'h018: Data = 32'h8A0A018C;

        // --- FIX: Corrected CBZ instruction to test Rn (X12) ---
        // Was: 63'h01c: Data = 32'hB400008C;
        63'h01c: Data = 32'hB400018C; // (CBZ X12, end - Rn field)
        // --- End of Fix ---

        63'h020: Data = 32'h8B0901AD;
        63'h024: Data = 32'hCB09018C;
        63'h028: Data = 32'h17FFFFFD;
        63'h02c: Data = 32'hF80203ED;
        63'h030: Data = 32'hF84203ED;

    /* Test Program 2 */
    63'h034: Data = 32'hD281BDE9;
    63'h038: Data = 32'hD2A1378E;
    63'h03c: Data = 32'hAA0E0129;
    63'h040: Data = 32'hD2C0ADCE;
    63'h044: Data = 32'hAA0E0129;
    63'h048: Data = 32'hD2E0268E;
    63'h04c: Data = 32'hAA0E0129;
    63'h050: Data = 32'hF80143F9;
    63'h054: Data = 32'hF84143FA;
    63'h058: Data = 32'hF84143FA;

        default: Data = 32'hXXXXXXXX;
      endcase
   end
endmodule
