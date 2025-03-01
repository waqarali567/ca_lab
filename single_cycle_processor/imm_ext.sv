module imm_ext #(
    X_LEN = 32
) (
    input  logic [X_LEN-1:0] instr_i,
    input  logic [1:0]       IMM_SEL_i,
    output logic [X_LEN-1:0] imm_ext_val_o
);

    always_comb begin
        case(IMM_SEL_i)
        2'b00: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[31:20]};
        2'b01: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        2'b10: imm_ext_val_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        endcase
    end
    
    
endmodule