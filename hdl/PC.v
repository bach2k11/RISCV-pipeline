
module PC_Module (
    input clk,rst,
    input [31:0]PC_Next,
    input StallF,
    output reg [31:0]PC

);
    
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0)
            PC <= {32{1'b0}};
        else if (~StallF)begin
            PC <= PC_Next;
             end
        end
            
endmodule