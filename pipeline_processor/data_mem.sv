module data_mem #(
    X_LEN = 32
) (
    input  logic                clk_i, 
    input  logic                rst_n_i,
    input  logic                WE_i,
    input  logic [X_LEN-1:0]    wb_addr_i,
    input  logic [X_LEN-1:0]    wb_data_i,
    output logic [X_LEN-1:0]    wb_data_o
);

    logic [X_LEN-1:0] data_mem [0:1023];
    integer i;

    always_ff @(posedge clk_i) begin
        if(!rst_n_i) begin
            for (i = 0; i < 1024; i = i + 1) begin
                data_mem[i] = i;  // Initialize all memory locations with 0
            end
        end
        else if(WE_i) begin
            data_mem[wb_addr_i[31:2]] <= wb_data_i;
        end
    end

    assign wb_data_o = data_mem[wb_addr_i[31:2]];
    
endmodule