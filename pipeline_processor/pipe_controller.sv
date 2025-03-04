module pipe_controller #(
    parameter X_LEN = 32
) (
    input  logic [X_LEN-1:0] instr_i,
    input  logic [4:0] rd_addr_i,
    input  logic [4:0] rs1_addr_i,
    input  logic [4:0] rs2_addr_i,
    input  logic [X_LEN-1:0] rs1_data_i,
    input  logic [X_LEN-1:0] rs2_data_i,
    output logic FWD_A_o,
    output logic FWD_B_o,
    output logic PC_SEL_o,
    output logic [2:0] IMM_SEL_o,    
    output logic REG_WRITE_o,
    output logic A_SEL_o,
    output logic B_SEL_o,     
    output logic [3:0] ALU_OP_o, 
    output logic WE_o,         
    output logic [1:0] WB_SEL_o
);

    //opcode, funct3, and funct7 fields
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    assign opcode = instr_i[6:0];   // Opcode (7 bits)
    assign func3  = instr_i[14:12]; // Funct3 (3 bits)
    assign func7  = instr_i[31:25]; // Funct7 (7 bits)

    //Forwarding
    assign FWD_A_o = (((rs1_addr_i == rd_addr_i) & REG_WRITE_o) & (rs1_addr_i != 0)); 
    assign FWD_B_o = (((rs2_addr_i == rd_addr_i) & REG_WRITE_o) & (rs2_addr_i != 0)); 

    always_comb begin
        PC_SEL_o        = 1'b0;
        IMM_SEL_o       = 3'b000; 
        REG_WRITE_o     = 1'b0;
        A_SEL_o         = 1'b0; 
        B_SEL_o         = 1'b0;
        ALU_OP_o        = 4'b0000;
        WE_o            = 1'b0;
        WB_SEL_o        = 2'b00;

        case(opcode)

            //R-type instructions (opcode = 0110011)
            7'b0110011: begin
                REG_WRITE_o = 1'b1;
                case (func3)
                    3'b000: ALU_OP_o = (func7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: ALU_OP_o = 4'b0101; // SLL
                    3'b010: ALU_OP_o = 4'b1000; // SLT
                    3'b011: ALU_OP_o = 4'b1001; // SLTU
                    3'b100: ALU_OP_o = 4'b0100; // XOR
                    3'b101: ALU_OP_o = (func7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: ALU_OP_o = 4'b1010; // OR
                    3'b111: ALU_OP_o = 4'b1011; // AND
                endcase
            end

            //I-type instructions (opcode = 0010011 & 0000011(for Load instructions))
            7'b0010011: begin
                REG_WRITE_o = 1'b1;
                B_SEL_o     = 1'b1;
                case (func3)
                    3'b000: ALU_OP_o = 4'b0000; // ADDi
                    3'b001: ALU_OP_o = 4'b0101; // SLLi
                    3'b010: ALU_OP_o = 4'b1000; // SLTi
                    3'b011: ALU_OP_o = 4'b1001; // SLTUi
                    3'b100: ALU_OP_o = 4'b0100; // XORi
                    3'b101: ALU_OP_o = (func7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRAi : SRLi
                    3'b110: ALU_OP_o = 4'b1010; // ORi
                    3'b111: ALU_OP_o = 4'b1011; // ANDi
                endcase
            end
        
            //Load Instructions --> I-Type (different load types are handled in top file)
            7'b0000011: begin
                REG_WRITE_o = 1'b1;
                B_SEL_o     = 1'b1;
            end

            //JALR --> I-Type
            7'b1100111: begin
                REG_WRITE_o = 1'b1;
                B_SEL_o     = 1'b1;
                PC_SEL_o    = 1'b1;
                WB_SEL_o    = 2'b10;
            end

            //Store Instruction (different store types are handled in top file)
            7'b0100011: begin
                IMM_SEL_o = 3'b001;
                B_SEL_o   = 1'b1;
                WE_o      = 1'b1;
            end

            //Branch Instruction
            7'b1100011: begin
                case(func3)
                    3'b000: begin //BEQ (Branch if Equal)
                        PC_SEL_o = (rs1_data_i == rs2_data_i) ? 1'b1 : 1'b0;
                        A_SEL_o  = (rs1_data_i == rs2_data_i) ? 1'b1 : 1'b0;
                    end
                    3'b001: begin //BNE (Branch if Not Equal)
                        PC_SEL_o = (rs1_data_i != rs2_data_i) ? 1'b1 : 1'b0;
                        A_SEL_o  = (rs1_data_i != rs2_data_i) ? 1'b1 : 1'b0;
                    end
                    3'b100: begin //BLT (Branch if Less Than, Signed)
                        PC_SEL_o = ($signed(rs1_data_i) < $signed(rs2_data_i)) ? 1'b1 : 1'b0;
                        A_SEL_o  = ($signed(rs1_data_i) < $signed(rs2_data_i)) ? 1'b1 : 1'b0;
                    end
                    3'b101: begin //BGE (Branch if Greater Than or Equal, Signed)
                        PC_SEL_o = ($signed(rs1_data_i) >= $signed(rs2_data_i)) ? 1'b1 : 1'b0;
                        A_SEL_o  = ($signed(rs1_data_i) >= $signed(rs2_data_i)) ? 1'b1 : 1'b0;
                    end
                    3'b110: begin //BLTU (Branch if Less Than, Unsigned)
                        PC_SEL_o = (rs1_data_i < rs2_data_i) ? 1'b1 : 1'b0;
                        A_SEL_o  = (rs1_data_i < rs2_data_i) ? 1'b1 : 1'b0;
                    end
                    3'b111: begin //BGEU (Branch if Greater Than or Equal, Unsigned)
                        PC_SEL_o = (rs1_data_i >= rs2_data_i) ? 1'b1 : 1'b0;
                        A_SEL_o  = (rs1_data_i >= rs2_data_i) ? 1'b1 : 1'b0;
                    end
                endcase
            end

            //Jump Instruction

            //JAL
            7'b1101111: begin
                IMM_SEL_o    = 3'b011;
                PC_SEL_o     = 1'b1;
                REG_WRITE_o  = 1'b1;
                B_SEL_o      = 1'b1;
                WB_SEL_o     = 2'b10;
            end

            //U Instruction

            //AUIPC
            7'b0010111: begin
                IMM_SEL_o    = 3'b100;
                REG_WRITE_o  = 1'b1;
                B_SEL_o      = 1'b1;
                WB_SEL_o     = 2'b01;
            end

            //LUI
            7'b0110111: begin
                IMM_SEL_o    = 3'b100;
                REG_WRITE_o  = 1'b1;
                B_SEL_o      = 1'b1;
                WB_SEL_o     = 2'b01;
            end
        endcase

    end

endmodule
