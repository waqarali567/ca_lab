module imm_ext #(
    X_LEN = 32
) (
    input  logic [X_LEN-1:0] instr_i,
    input  logic [2:0]       IMM_SEL_i,
    output logic [X_LEN-1:0] imm_ext_val_o
);

    always_comb begin
        case(IMM_SEL_i)
        3'b000: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[31:20]};                                         //I-Type
        3'b001: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};                          //S-Type
        3'b010: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};        //B-Type
        3'b011: imm_ext_val_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};      //J-Type
        3'b100: imm_ext_val_o = {instr_i[31:12], 12'b0};                                                     //U-Type
        endcase
    end
    
    
endmodule