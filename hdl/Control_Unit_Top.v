
module Control_Unit_Top ( 
    input     [6:0] Op, funct7,
    input     [2:0] funct3,

    output          RegWrite, 
    output          ALUSrc,     // 0: Rd2,  1: Imm
    output          MemWrite,
    output          Branch,     // B type
    output          Jump,
    output    [1:0] ResultSrc,
    output    [2:0] ImmSrc,
    output    [3:0] ALUControl
);
    reg  [9:0]  controls;
    reg  [3:0]  alu_ctl;

    wire        funct7b5 = funct7[5];        

    assign {RegWrite, ImmSrc, ALUSrc, Branch, MemWrite, ResultSrc, Jump} = controls;
    assign ALUControl = alu_ctl;    

    // opcode
    localparam [6:0]
        OP_LUI    = 7'b0110111,
        OP_AUIPC  = 7'b0010111,
        OP_JAL    = 7'b1101111,
        OP_JALR   = 7'b1100111,
        OP_BRANCH = 7'b1100011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_ALUI   = 7'b0010011,
        OP_R      = 7'b0110011;

    // ALU Op
    localparam [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLT  = 4'b0101,
        ALU_SLTU = 4'b0110,
        ALU_SLL  = 4'b0111,
        ALU_SRL  = 4'b1000,
        ALU_SRA  = 4'b1001;

    // ---------------- Control Signals ----------------
    // {RegWrite, ImmSrc, ALUSrc, Branch, MemWrite, ResultSrc, Jump}
    always @(Op) begin
        controls = 10'b0_000_0_0_0_00_0; 

        case (Op)
            // U type
            OP_LUI:    controls = 10'b1_100_1_0_0_00_0;
            OP_AUIPC:  controls = 10'b1_100_1_0_0_00_0;

            // J type
            OP_JAL:    controls = 10'b1_011_0_0_0_10_1;
            OP_JALR:   controls = 10'b1_000_1_0_0_10_1;

            // Branch
            OP_BRANCH: controls = 10'b0_010_0_1_0_00_0;

            // Load/Store
            OP_LOAD:   controls = 10'b1_000_1_0_0_01_0;
            OP_STORE:  controls = 10'b0_001_1_0_1_00_0;

            // I type
            OP_ALUI:   controls = 10'b1_000_1_0_0_00_0;

            // R type
            OP_R:      controls = 10'b1_000_0_0_0_00_0;
            default:   controls = 10'b0_000_0_0_0_00_0;
        endcase
    end

    // ---------------- ALU Control ----------------
    always @(Op or funct3 or funct7b5) begin
        alu_ctl = ALU_ADD; // default

        case (Op)
            OP_R: begin
                case (funct3)
                    3'b000: alu_ctl = funct7b5 ? ALU_SUB : ALU_ADD;
                    3'b111: alu_ctl = ALU_AND;
                    3'b110: alu_ctl = ALU_OR;
                    3'b100: alu_ctl = ALU_XOR;
                    3'b010: alu_ctl = ALU_SLT;
                    3'b011: alu_ctl = ALU_SLTU;
                    3'b001: alu_ctl = ALU_SLL;
                    3'b101: alu_ctl = funct7b5 ? ALU_SRA : ALU_SRL;
                    default: alu_ctl = ALU_ADD;
                endcase
            end

            OP_ALUI: begin
                case (funct3)
                    3'b000: alu_ctl = ALU_ADD;                   // addi
                    3'b010: alu_ctl = ALU_SLT;                   // slti
                    3'b011: alu_ctl = ALU_SLTU;                  // sltiu
                    3'b100: alu_ctl = ALU_XOR;                   // xori
                    3'b110: alu_ctl = ALU_OR;                    // ori
                    3'b111: alu_ctl = ALU_AND;                   // andi
                    3'b001: alu_ctl = ALU_SLL;                   // slli
                    3'b101: alu_ctl = funct7b5 ? ALU_SRA : ALU_SRL; // srai/srli
                    default: alu_ctl = ALU_ADD;
                endcase
            end

            OP_LOAD, OP_STORE: begin
                alu_ctl = ALU_ADD; // rd = rs1 + imm
            end

            OP_AUIPC: begin
                alu_ctl = ALU_ADD; // PC + immU
            end

            OP_LUI: begin
                alu_ctl = ALU_ADD; // 0 + immU (SrcA=0 khi SelA=1 & U-type)
            end

            OP_JALR: begin
                alu_ctl = ALU_ADD; // rs1 + immI (PCNext lấy từ ALUResult&~1)
            end

            default: begin
                alu_ctl = ALU_ADD;
            end
        endcase
    end

endmodule
