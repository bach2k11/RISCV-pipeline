// 0000 ADD   | 0001 SUB   | 0010 AND   | 0011 OR
// 0100 XOR   | 0101 SLT   | 0110 SLTU  | 0111 SLL
// 1000 SRL   | 1001 SRA   

module ALU (   
    input       [31:0]  A, B,
    input       [3:0]   ALUControl,

    output  reg [31:0]  Result,
    output              zero
);

    always @(ALUControl or A or B) begin
        case (ALUControl)
            4'b0000: Result = A + B;                                       // ADD
            4'b0001: Result = A - B;                                       // SUB
            4'b0010: Result = A & B;                                       // AND
            4'b0011: Result = A | B;                                       // OR
            4'b0100: Result = A ^ B;                                       // XOR
            4'b0101: Result = ($signed(A) <  $signed(B)) ? 32'd1 : 32'd0;  // SLT  (signed)
            4'b0110: Result = (A < B)                    ? 32'd1 : 32'd0;  // SLTU (unsigned)
            4'b0111: Result = A <<  B[4:0];                                // SLL
            4'b1000: Result = A >>  B[4:0];                                // SRL
            4'b1001: Result = $signed(A) >>> B[4:0];                       // SRA
            default: Result = 32'h0;
        endcase
    end

    assign zero      = (Result == 32'b0);

endmodule