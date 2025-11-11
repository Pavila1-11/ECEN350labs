module SingleCycleProc(
                   input             reset, //Active High
                   input [63:0]      startpc,
                   output reg [63:0] currentpc,
                   output [63:0]     MemtoRegOut, // To testbench
                   input             CLK
                   );

    // --- Wires ---
    wire [63:0] nextpc;
    wire [31:0] instruction;
    wire [10:0] opcode;
    wire        Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncon>
    wire [3:0]  ALUop;
    wire [1:0]  SignOp;
    wire [63:0] regoutA, regoutB, write_data;
    wire [4:0]  rw_addr;
    wire [63:0] extimm;
    wire [63:0] alu_in_B, aluout;
    wire        zero;
    wire [63:0] dm_read_data;

    // --- PC Update Logic ---
    always @(posedge CLK)
    begin
        if (reset)
            currentpc <= #3 startpc;
        else
            currentpc <= #3 nextpc;
    end

    // --- Datapath ---
  // Instruction Memory
    InstructionMemory imem( .Data(instruction), .Address(currentpc) );

    // Extract opcode
    assign opcode = instruction[31:21];

    // Control Unit
    SC_Control control(
        .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite),
        .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Uncondbranch(Uncond>
        .ALUOp(ALUop), .SignOp(SignOp), .opcode(opcode)
    );

    // Sign Extender
    SignExtender signex(
        .SignExOut(extimm), .Instruction(instruction[25:0]), .SignOp(SignOp)
    );

    // MUX for Write Register Address (RW)
    assign rw_addr = Reg2Loc ? instruction[20:16] : instruction[4:0];

    // Register File
    RegisterFile rf(
        .BusA(regoutA), .BusB(regoutB), .BusW(write_data),
        .RA(instruction[9:5]),   // Rn
        .RB(instruction[20:16]), // Rm
        .RW(rw_addr),            // Rd or Rt (for STUR)
        .RegWr(RegWrite), .Clk(CLK)
    );

    // MUX for ALU Input B
    assign alu_in_B = ALUSrc ? extimm : regoutB;
  // ALU
    ALU alu(
        .BusW(aluout), .BusA(regoutA), .BusB(alu_in_B), .ALUCtrl(ALUop), .Zero(zero)
    );

    // Data Memory
    DataMemory dmem(
        .ReadData(dm_read_data), .Address(aluout), .WriteData(regoutB),
        .MemoryRead(MemRead), .MemoryWrite(MemWrite), .Clock(CLK)
    );

    // MUX for Write-Back Data (MemtoReg)
    assign write_data = MemtoReg ? dm_read_data : aluout;

    // Assign output for testbench
    assign MemtoRegOut = write_data;

    // Next PC Logic Unit
    NextPClogic npc(
        .NextPC(nextpc), .CurrentPC(currentpc), .SignExtImm64(extimm),
        .Branch(Branch), .ALUZero(zero), .Uncondbranch(Uncondbranch)
    );

endmodule




