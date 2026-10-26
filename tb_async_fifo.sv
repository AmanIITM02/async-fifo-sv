module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    logic                  wclk, wrst_n, w_inc, wfull;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  rclk, rrst_n, r_inc, rempty;
    logic [DATA_WIDTH-1:0] rdata;

    // Instantiate Async FIFO DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (.*);

    // Asynchronous Clocks: Write = 100 MHz (10ns period), Read = 40 MHz (25ns period)
    always #5  wclk = ~wclk;
    always #12.5 rclk = ~rclk;

    initial begin
        $dumpfile("fifo_trace.vcd");
        $dumpvars(0, tb_async_fifo);

        // Initialize Signals
        wclk   = 0; wrst_n = 0; w_inc = 0; wdata = 0;
        rclk   = 0; rrst_n = 0; r_inc = 0;

        #30 wrst_n = 1; rrst_n = 1;

        $display("\n=== STARTING ASYNC FIFO TESTBENCH ===");

        // --- WRITE TEST PATTERN (Burst Writes) ---
        @(posedge wclk);
        for (int i = 1; i <= 10; i++) begin
            @(posedge wclk);
            w_inc = 1;
            wdata = i * 10;
            $display("[WRITE] Time: %0t | Data Pushed: %0d | Full: %0b", $time, wdata, wfull);
        end
        @(posedge wclk);
        w_inc = 0;

        #50;

        // --- READ TEST PATTERN (Concurrent Read Domain Extraction) ---
        for (int j = 1; j <= 10; j++) begin
            @(posedge rclk);
            r_inc = 1;
            @(posedge rclk);
            r_inc = 0;
            $display("[READ]  Time: %0t | Data Popped: %0d | Empty: %0b", $time, rdata, rempty);
        end

        #100;
        $display("\n=== [SUCCESS] TESTBENCH COMPLETED CLEANLY ===\n");
        $finish;
    end

endmodule
