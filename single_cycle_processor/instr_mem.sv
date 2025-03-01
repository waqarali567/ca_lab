module instr_mem #(
    X_LEN = 32
) (
    input                     rst_n_i,
    input  logic [X_LEN-1:0]  pc_i,
    output logic [X_LEN-1:0]  instr_o
);

    logic [X_LEN-1:0] instr_mem [0:1023];

    initial begin
        $readmemh("instruction.mem", instr_mem); // Load instructions from file
    end

    assign instr_o = (!rst_n_i) ? 32'd0 : instr_mem[pc_i[31:2]];
    
endmodule