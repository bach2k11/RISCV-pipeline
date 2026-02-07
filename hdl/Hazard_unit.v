
module hazard_unit (
    // Declaration of I/Os
    input               rst, 
    input               RegWriteM, 
    input               RegWriteW,

    input       [4:0]   RD_M, RD_W, Rs1_E, Rs2_E,
    output      [1:0]   ForwardAE, ForwardBE,

    input       [4:0]   Rs1_D, Rs2_D,
    input       [4:0]   RD_E,
    input       [1:0]   ResultSrcE,
    input               PCSrcE,

    output              StallF, StallD, FlushE, FlushD
);
    
    assign ForwardAE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RD_M != 5'h00) & (RD_M == Rs1_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) & (RD_W != 5'h00) & (RD_W == Rs1_E)) ? 2'b01 : 2'b00;
                       
    assign ForwardBE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RD_M != 5'h00) & (RD_M == Rs2_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) & (RD_W != 5'h00) & (RD_W == Rs2_E)) ? 2'b01 : 2'b00;

    wire lwstall;

    assign lwStall = (ResultSrcE[0] == 1'b1) & 
                     ((RD_E == Rs1_D) | (RD_E == Rs2_D));
    assign StallF = (rst == 1'b0) ? 1'b0 : lwStall;
    assign StallD = (rst == 1'b0) ? 1'b0 : lwStall;


    assign FlushE = (rst == 1'b0) ? 1'b0 : (lwStall | PCSrcE);
    assign FlushD = (rst == 1'b0) ? 1'b0 : PCSrcE;

endmodule
