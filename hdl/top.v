module top (
    input clk, rst,
    output [31:0] RD,
    //dmem
    output  MemWriteM,
    output [31:0] ReadDataM,
    output [31:0] WriteDataM
);
wire [31:0] PCF;
wire [31:0] ALU_ResultM;

core core(
    .clk(clk),
    .rst(rst),

    .RD(RD),
    .PCF(PCF),
    //dmem
    .ALU_ResultM(ALU_ResultM),
    .WriteDataM(WriteDataM),
    .MemWriteM(MemWriteM),
    .ReadDataM(ReadDataM)
);
    
Instruction_Memory imem (
    .rst(rst),
    .A(PCF),
    .RD(RD)
);

Data_Memory dmem (
    .clk(clk),
    .rst(rst),
    .WE(MemWriteM),
    .A(ALU_ResultM),
    .WD(WriteDataM),
    .RD(ReadDataM)
);
endmodule