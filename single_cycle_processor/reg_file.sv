module reg_file #(
    parameter X_LEN = 32
) (
    input  logic              clk_i,
    input  logic              rst_n_i,
    input  logic              REG_WRITE_i, // Control signal
    input  logic [4:0]        rs1_addr_i,
    input  logic [4:0]        rs2_addr_i,
    input  logic [4:0]        rd_addr_i,
    input  logic [X_LEN-1:0]  wb_data_i, // Write Back Data
    output logic [X_LEN-1:0]  rs1_data_o,
    output logic [X_LEN-1:0]  rs2_data_o
);
    logic [X_LEN-1:0] reg_file [0:31]; // 32 Registers
    integer i;

    // Register Initialization using a for loop
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= i;  // Assign each register with its index value
            end
        end 
        else if (REG_WRITE_i & (rd_addr_i != 5'd0)) begin
            reg_file[rd_addr_i] <= wb_data_i;
        end
    end

    // Register Read
    assign rs1_data_o = (~rst_n_i) ? 32'd0 : reg_file[rs1_addr_i];
    assign rs2_data_o = (~rst_n_i) ? 32'd0 : reg_file[rs2_addr_i];

endmodule
