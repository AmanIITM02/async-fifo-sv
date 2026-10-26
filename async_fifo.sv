// async_fifo.sv - Parameterized Asynchronous FIFO with CDC Logic
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4  // FIFO Depth = 2^4 = 16
)(
    // Write Domain
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  w_inc,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic                  wfull,

    // Read Domain
    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  r_inc,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  rempty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Memory Array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers
    logic [ADDR_WIDTH:0] wptr_bin, wptr_gray;
    logic [ADDR_WIDTH:0] rptr_bin, rptr_gray;
    logic [ADDR_WIDTH:0] wq2_rptr, rq2_wptr;
    logic [ADDR_WIDTH:0] wq1_rptr, rq1_wptr;

    // --- WRITE DOMAIN LOGIC ---
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
        end else if (w_inc && !wfull) begin
            mem[wptr_bin[ADDR_WIDTH-1:0]] <= wdata;
            wptr_bin  <= wptr_bin + 1'b1;
            wptr_gray <= (wptr_bin + 1'b1) ^ ((wptr_bin + 1'b1) >> 1);
        end
    end

    // --- READ DOMAIN LOGIC ---
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
            rdata     <= '0;
        end else if (r_inc && !rempty) begin
            rdata     <= mem[rptr_bin[ADDR_WIDTH-1:0]];
            rptr_bin  <= rptr_bin + 1'b1;
            rptr_gray <= (rptr_bin + 1'b1) ^ ((rptr_bin + 1'b1) >> 1);
        end
    end

    // --- 2-FLOP SYNCHRONIZERS (CDC) ---
    // Synchronize Read Pointer into Write Domain
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wq1_rptr <= '0;
            wq2_rptr <= '0;
        end else begin
            wq1_rptr <= rptr_gray;
            wq2_rptr <= wq1_rptr;
        end
    end

    // Synchronize Write Pointer into Read Domain
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rq1_wptr <= '0;
            rq2_wptr <= '0;
        end else begin
            rq1_wptr <= wptr_gray;
            rq2_wptr <= rq1_wptr;
        end
    end

    // --- FULL AND EMPTY FLAGS ---
    assign wfull  = (wptr_gray == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});
    assign rempty = (rptr_gray == rq2_wptr);

    // --- PROCEDURAL ASSERTION CHECKS ---
    always_ff @(posedge wclk) begin
        if (wrst_n && wfull && w_inc) begin
            $display("[SVA ERROR] Write Overflow Attempted at Time %0t!", $time);
        end
    end

    always_ff @(posedge rclk) begin
        if (rrst_n && rempty && r_inc) begin
            $display("[SVA ERROR] Read Underflow Attempted at Time %0t!", $time);
        end
    end

endmodule
