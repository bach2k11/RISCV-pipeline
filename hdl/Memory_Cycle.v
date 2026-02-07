
module memory_cycle (
    // Declaration of I/Os
    input               clk, 
    input               rst, 
    
    input               RegWriteM, 
    

    input       [1:0]   ResultSrcM,
    input       [4:0]   RD_M,
    input       [31:0]  PCPlus4M,

    //  WriteDataM,     
    // input               MemWriteM, 
     input       [31:0]  ALU_ResultM,
     output  reg [31:0] ReadDataW,

    input [31:0] ReadDataM,

    output  reg         RegWriteW, 
    output  reg [1:0]   ResultSrcW,
    output  reg [4:0]   RD_W,
    output  reg [31:0]  PCPlus4W, ALU_ResultW

);

    // Declaration of Interim Wires


    // Declaration of Module Initiation
    // Data_Memory dmem (
    //                     .clk(clk),
    //                     .rst(rst),
    //                     .WE(MemWriteM),
    //                     .WD(WriteDataM),
    //                     .A(ALU_ResultM),
    //                     .RD(ReadDataM)
    //                 );

    // Memory Stage Register Logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteW   <= 1'b0; 
            ResultSrcW  <= 2'b0;
            RD_W        <= 5'h00;
            PCPlus4W    <= 32'h00000000; 
            ALU_ResultW <= 32'h00000000; 
            ReadDataW   <= 32'h00000000;
        end
        else begin
            RegWriteW   <= RegWriteM; 
            ResultSrcW  <= ResultSrcM;
            RD_W        <= RD_M;
            PCPlus4W    <= PCPlus4M; 
            ALU_ResultW <= ALU_ResultM; 
            ReadDataW   <= ReadDataM;
        end
    end 


endmodule
