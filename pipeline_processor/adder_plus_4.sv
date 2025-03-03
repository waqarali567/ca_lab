module adder_plus_4 #(
    X_LEN = 32
) (
    input  logic [X_LEN-1:0] a_i,
    input  logic [X_LEN-1:0] b_i,
    output logic [X_LEN-1:0] c_o
);

    assign c_o = a_i + b_i;
    
endmodule