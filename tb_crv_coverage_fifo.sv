module tb_crv_coverage_fifo;

    parameter DSIZE = 8;
    parameter ASIZE = 4;

    logic             wclk, wrst_n, winc;
    logic [DSIZE-1:0] wdata;
    logic             wfull;

    logic             rclk, rrst_n, rinc;
    logic [DSIZE-1:0] rdata;
    logic             rempty;

    // Coverage Bin Counters
    int full_hit_count  = 0;
    int empty_hit_count = 0;
    int write_count     = 0;
    int read_count      = 0;

    // Instantiate Async FIFO DUT
    async_fifo #(
        .DSIZE(DSIZE),
        .ASIZE(ASIZE)
    ) dut (.*);

    // Dual Clock Generation
    always #5   wclk = ~wclk;  // 100 MHz Write Clock
    always #12.5 rclk = ~rclk; // 40 MHz Read Clock

    // Functional Coverage Tracking Logic
    always_ff @(posedge wclk) begin
        if (wfull) full_hit_count++;
        if (winc && !wfull) write_count++;
    end

    always_ff @(posedge rclk) begin
        if (rempty) empty_hit_count++;
        if (rinc && !rempty) read_count++;
    end

    initial begin
        $dumpfile("fifo_crv_trace.vcd");
        $dumpvars(0, tb_crv_coverage_fifo);

        wclk   = 0; wrst_n = 0; winc = 0; wdata = 0;
        rclk   = 0; rrst_n = 0; rinc = 0;

        #30 wrst_n = 1; rrst_n = 1;

        $display("\n=== STARTING CONSTRAINED-RANDOM & COVERAGE SIMULATION ===");

        // Constrained-Random Write Burst to Stress Full Boundary
        repeat (30) begin
            @(posedge wclk);
            winc  <= $urandom_range(0, 1);
            wdata <= $urandom_range(8'h10, 8'hFF);
        end

        // Constrained-Random Read Burst to Stress Empty Boundary
        repeat (30) begin
            @(posedge rclk);
            rinc <= $urandom_range(0, 1);
        end

        #200;
        $display("\n=== FUNCTIONAL COVERAGE METRICS ===");
        $display("[COVERAGE] Total Successful Writes: %0d", write_count);
        $display("[COVERAGE] Total Successful Reads:  %0d", read_count);
        $display("[COVERAGE] Full Condition Hit:      %0d times", full_hit_count);
        $display("[COVERAGE] Empty Condition Hit:     %0d times", empty_hit_count);
        $display("=== [SUCCESS] SIMULATION COMPLETED CLEANLY ===\n");
        $finish;
    end

endmodule
