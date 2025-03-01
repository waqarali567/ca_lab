module scp_top (
    input logic clk_i, 
    input logic rst_n_i
);

    //PC Selector
    logic [31:0] pc_next_sel;
    
    //PC Signals
    logic [31:0] pc_curr, pc_next, instr;

    //Immediate Extension Signals
    logic [31:0] imm_ext_val;
    
    //Register File Signals
    logic [6:0]  opcode;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [2:0]  func3;
    logic [31:0] rs1_data, rs2_data, wb_data;

    //ALU input selection
    logic [31:0] sel_a_i,sel_b_i;
    
    //ALU Signals
    logic [31:0] alu_out;

    //Store Types
    logic [31:0] wb_addr_store_type, wb_data_store_type;
    
    //Data Memory Signals
    logic [31:0] mem_out;

    //Write Back With Load Types
    logic [31:0] wb_data_load_type;

    //SCP Controller Signals
    logic PC_SEL;
    logic [1:0]  IMM_SEL;
    logic REG_WRITE;
    logic A_SEL, B_SEL;
    logic [3:0] ALU_OP;
    logic WE;
    logic WB_SEL;

    assign pc_next_sel = (PC_SEL) ? alu_out : pc_next;

    //PC Instance
    pc pc_inst (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .pc_next_i(pc_next_sel),
        .pc_o(pc_curr)
    );

    //PC Incrementer (PC + 4)
    adder_plus_4 adder_pc (
        .a_i(pc_curr),
        .b_i(32'd4),
        .c_o(pc_next)
    );

    //Instruction Memory Instance
    instr_mem instr_mem_inst (
        .rst_n_i(rst_n_i),
        .pc_i(pc_curr),  // Word-aligned instruction memory
        .instr_o(instr)
    );

    imm_ext imm_ext_inst(
        .instr_i(instr),
        .IMM_SEL_i(IMM_SEL),
        .imm_ext_val_o(imm_ext_val)
    );

    //Extract Fields from Instruction
    assign opcode   = instr[6:0]; 
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];
    assign func3    = instr[14:12];  // ALU operation from funct3

    //Register File Instance
    reg_file reg_file_inst (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .REG_WRITE_i(REG_WRITE),
        .rs1_addr_i(rs1_addr),
        .rs2_addr_i(rs2_addr),
        .rd_addr_i(rd_addr),
        .wb_data_i(wb_data),
        .rs1_data_o(rs1_data),
        .rs2_data_o(rs2_data)
    );

    assign sel_a_i = (A_SEL)? pc_curr     : rs1_data;
    assign sel_b_i = (B_SEL)? imm_ext_val : rs2_data;

    //ALU Instance
    alu alu_inst (
        .a_i(sel_a_i),
        .b_i(sel_b_i),
        .alu_op_i(ALU_OP),
        .c_o(alu_out)
    );

    assign wb_data_store_type = (opcode == 7'b0100011) ? (
                                (func3 == 3'b000) ? {24'b0, rs2_data[7:0]}  :
                                (func3 == 3'b001) ? {16'b0, rs2_data[15:0]} :
                                rs2_data
                                )
                                :rs2_data;
    assign wb_addr_store_type = (opcode == 7'b0100011) ? (
                                (func3 == 3'b000) ? {24'b0, alu_out[7:0]}  :
                                (func3 == 3'b001) ? {16'b0, alu_out[15:0]} :
                                alu_out
                                )
                                :alu_out;

    //Data Memory Instance
    data_mem data_mem_inst (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .WE_i(WE),
        .wb_addr_i(wb_addr_store_type),
        .wb_data_i(wb_data_store_type),
        .wb_data_o(mem_out)
    );

    assign wb_data_load_type = (opcode == 7'b0000011) ? (
                               (func3 == 3'b000) ? {{24{mem_out[7]}}, mem_out[7:0]}  :  // LB (Sign-extend byte)
                               (func3 == 3'b001) ? {{16{mem_out[15]}}, mem_out[15:0]} :  // LH (Sign-extend halfword)
                               (func3 == 3'b100) ? {24'b0, mem_out[7:0]}              :  // LBU (Zero-extend byte)
                               (func3 == 3'b101) ? {16'b0, mem_out[15:0]}             :  // LHU (Zero-extend halfword)
                               mem_out 
                               )                                               // LW (Load Word, no extension)
                               :mem_out;

    scp_controller scp_controller_inst(
                   .instr_i(instr),
                   .rs1_data_i(rs1_data),
                   .rs2_data_i(rs2_data),
                   .PC_SEL_o(PC_SEL),
                   .IMM_SEL_o(IMM_SEL),    
                   .REG_WRITE_o(REG_WRITE),
                   .A_SEL_o(A_SEL),
                   .B_SEL_o(B_SEL),     
                   .ALU_OP_o(ALU_OP), 
                   .WE_o(WE),         
                   .WB_SEL_o(WB_SEL)
                   );

    assign wb_data = (WB_SEL)? alu_out: wb_data_load_type;

endmodule
