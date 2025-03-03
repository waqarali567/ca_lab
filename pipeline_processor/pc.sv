module pc #(
    X_LEN = 32
) (
    input  logic                clk_i,
    input  logic                rst_n_i,
    input  logic [X_LEN-1:0]    pc_next_i,
    output logic [X_LEN-1:0]    pc_o
);

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)begin
            pc_o <= 0;
        end

        else begin
            pc_o <= pc_next_i;
        end
    end
 
    
endmodule