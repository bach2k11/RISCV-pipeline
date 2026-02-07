
module fetch_cycle (
    // Declare input & outputs
    input               clk, 
    input               rst,

    input               PCSrcE,
    input       [31:0]  PCTargetE,

    input               StallD,
    input               FlushD,
    input               StallF,
    
    output        [31:0] PCF,
    input       [31:0]  InstrF,

    output  reg [31:0]  InstrD,
    output  reg [31:0]  PCD, PCPlus4D
);
    // Declaring interim wires
    wire        [31:0]  PC_F, PCPlus4F;
    //wire        [31:0]  PCF;
    //wire        [31:0]  InstrF;

    assign PC_F = (~PCSrcE) ? PCPlus4F : PCTargetE;

    // Declare PC Counter
    PC_Module Program_Counter (
                            .clk(clk),
                            .rst(rst),
                            .PC(PCF),
                            .PC_Next(PC_F),
                            .StallF(StallF)
                        );

    // Declare Instruction Memory
    // Instruction_Memory IMEM (
    //                         .rst(rst),
    //                         .A(PCF),
    //                         .RD(InstrF)
    //                     );

    assign PCPlus4F = PCF + 32'h00000004;

    // Fetch Cycle Register Logic
    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            InstrD          <= 32'h00000000;
            PCD             <= 32'h00000000;
            PCPlus4D        <= 32'h00000000;
        end
        else if (~StallD) begin
            if (FlushD) begin
                InstrD      <= 32'h00000000;
                PCD         <= 32'h00000000;
                PCPlus4D    <= 32'h00000000;
            end
            else begin
                InstrD      <= InstrF;
                PCD         <= PCF;
                PCPlus4D    <= PCPlus4F;
            end
        end
    end

endmodule
