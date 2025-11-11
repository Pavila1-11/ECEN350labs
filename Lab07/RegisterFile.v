module RegisterFile(
    output wire [63:0] BusA,
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA,
    input  wire [4:0]  RB,
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);
    reg [63:0] register_file [0:31];

    // --- FIX: Initialize all registers to 0 ---
    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            register_file[i] = 64'b0;
        end
    end
    // --- End of Fix ---

    assign #3 BusA = (RA == 5'd31) ? 64'b0 : register_file[RA];
    assign #3 BusB = (RB == 5'd31) ? 64'b0 : register_file[RB];

    always @(posedge Clk) begin
        if (RegWr && (RW != 5'd31)) begin
            register_file[RW] <= BusW;
        end
    end
endmodule

