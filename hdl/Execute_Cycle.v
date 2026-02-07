
module execute_cycle (
    // Declaration I/Os
    input               clk, 
    input               rst, 
    
    input               RegWriteE,
    input               ALUSrcE,
    input               MemWriteE,
    input               BranchE, 
    input               JumpE,

    input       [1:0]   ResultSrcE,
    input       [3:0]   ALUControlE,
    input       [31:0]  RD1_E, RD2_E, Imm_Ext_E,
    input       [4:0]   RD_E,
    input       [31:0]  PCE, PCPlus4E,
    input       [31:0]  ResultW,
    input       [2:0]   funct3E,

    input       [1:0]   ForwardA_E, ForwardB_E,

    output              PCSrcE, 
    output  reg         RegWriteM, 
    output  reg         MemWriteM,
    output  reg [1:0]   ResultSrcM,
    output  reg [4:0]   RD_M,
    output  reg [31:0]  PCPlus4M, WriteDataM, ALU_ResultM,
    output      [31:0]  PCTargetE

);
    // Declaration of Interim Wires
    wire        [31:0]  Src_A, Src_B_interim, Src_B;
    wire        [31:0]  ResultE;
    wire                br_taken;


    // 3 by 1 Mux for Source A
    assign Src_A = (ForwardA_E == 2'b00) ? RD1_E : (ForwardA_E == 2'b01) ? ResultW : (ForwardA_E == 2'b10) ? ALU_ResultM : 32'h00000000;

    // 3 by 1 Mux for Source B
    assign Src_B_interim = (ForwardB_E == 2'b00) ? RD2_E : (ForwardB_E == 2'b01) ? ResultW : (ForwardB_E == 2'b10) ? ALU_ResultM : 32'h00000000;
   
    // ALU Src Mux
    assign Src_B = (~ALUSrcE) ? Src_B_interim : Imm_Ext_E ;

    // Branch condition
    Branch br (
                .funct3  (funct3E),
                .branch  (BranchE),
                .Rd1     (Src_A),
                .Rd2     (Src_B_interim),
                .br_taken(br_taken)
            ); 

    // ALU Unit
    ALU alu (
                .A(Src_A),
                .B(Src_B),
                .Result(ResultE),
                .ALUControl(ALUControlE),
                .zero()
            );

    assign PCTargetE = PCE + Imm_Ext_E;

    // Register Logic
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            RegWriteM   <= 1'b0; 
            MemWriteM   <= 1'b0; 
            ResultSrcM  <= 1'b0;
            RD_M        <= 5'h00;
            PCPlus4M    <= 32'h00000000; 
            WriteDataM  <= 32'h00000000; 
            ALU_ResultM <= 32'h00000000;
        end
        else begin
            RegWriteM   <= RegWriteE; 
            MemWriteM   <= MemWriteE; 
            ResultSrcM  <= ResultSrcE;
            RD_M        <= RD_E;
            PCPlus4M    <= PCPlus4E; 
            WriteDataM  <= Src_B_interim; 
            ALU_ResultM <= ResultE;
        end
    end

    // Output Assignments
    assign PCSrcE = br_taken | JumpE;

endmodule
