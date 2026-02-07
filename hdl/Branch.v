 module Branch (
    input  [2:0]  funct3,
    input         branch,
    input  [31:0] Rd1,    // rs1
    input  [31:0] Rd2,    // rs2
    output reg    br_taken
);
    // funct3
    localparam [2:0] BEQ  = 3'b000,
                     BNE  = 3'b001,
                     BLT  = 3'b100,
                     BGE  = 3'b101,
                     BLTU = 3'b110,
                     BGEU = 3'b111;


    always @(Rd1 or Rd2 or funct3 or branch) begin
        br_taken = 1'b0;
        if (branch) begin
            case (funct3)
                BEQ:  br_taken = (Rd1 == Rd2);                    // BEQ
                BNE:  br_taken = (Rd1 != Rd2);                    // BNE
                BLT:  br_taken = ($signed(Rd1) <  $signed(Rd2));  // BLT  (signed)
                BGE:  br_taken = ($signed(Rd1) >= $signed(Rd2));  // BGE  (signed)
                BLTU: br_taken = (Rd1 <  Rd2);                    // BLTU (unsigned)
                BGEU: br_taken = (Rd1 >= Rd2);                    // BGEU (unsigned)
                default: br_taken = 1'b0;
            endcase
        end else begin
            br_taken = 1'b0;
        end
    end
endmodule