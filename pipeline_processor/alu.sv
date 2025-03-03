module alu #(
    parameter X_LEN = 32
) (
    input  logic [X_LEN-1:0] a_i,  
    input  logic [X_LEN-1:0] b_i,  
    input  logic [3:0] alu_op_i,      
    output logic [X_LEN-1:0] c_o
);

    always_comb begin
        case (alu_op_i)
            4'b0000: c_o = a_i + b_i;                                       //ADD
            4'b0001: c_o = a_i - b_i;                                       //SUB
            4'b0100: c_o = a_i ^ b_i;                                       //XOR
            4'b0101: c_o = a_i << b_i[4:0];                                 //SLL
            4'b0110: c_o = a_i >> b_i[4:0];                                 //SRL
            4'b0111: c_o = $signed(a_i) >>> b_i[4:0];                       //SRA
            4'b1000: c_o = ($signed(a_i) < $signed(b_i)) ? 32'd1 : 32'd0;   //SLT (Signed)
            4'b1001: c_o = (a_i < b_i) ? 32'd1 : 32'd0;                     //SLTU (Unsigned)
            4'b1011: c_o = a_i & b_i;                                       //AND
            4'b1010: c_o = a_i | b_i;                                       //OR
            default: c_o = 32'd0;                                           //Default case
        endcase
    end

endmodule
