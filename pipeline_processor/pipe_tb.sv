module pipe_top_tb;

    logic clk;
    logic rst_n;

    pipe_top dut (
        .clk_i(clk),
        .rst_n_i(rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;

        #5;
        rst_n = 1;

        #200;       // Let system run for a while
        
        $stop;
    end

    initial begin
        $dumpfile("pipe.vcd"); // VCD File Name
        $dumpvars(0, pipe_top_tb);
    end

endmodule
