# Parameterized Asynchronous FIFO with Assertion-Based Verification (ABV)

A high-performance, parameterized Asynchronous FIFO (First-In, First-Out) architecture written in SystemVerilog (IEEE 1800). This design safely transfers multi-bit data across unsynchronized Clock Domain Crossings (CDC) without risking metastability, data corruption, or multi-bit bus-skew errors.

---

## Architecture & CDC Engineering

Modern System-on-Chip (SoC) architectures require reliable communication between independent clock domains. This module implements robust hardware mitigations for CDC hazards:

* Dual-Clock Domain Isolation: Write domain (wclk) and Read domain (rclk) operate completely asynchronously with independent frequency and phase relationships.
* Gray Code Pointer Conversion: Binary read/write pointers are converted to Gray code before crossing clock boundaries. Gray pointers guarantee that only a single bit toggles per clock transition, eliminating multi-bit bus skew.
* 2-Stage Flip-Flop Synchronizers: Cross-domain pointers are synchronized via cascaded 2-flop synchronizer pipelines (wq2_rptr, rq2_wptr) to allow metastable signals to safely settle before consumption.
* Pessimistically Safe Flag Logic:
  * rempty Flag: Evaluated in the read domain when the local Gray pointer matches the synchronized write pointer.
  * wfull Flag: Evaluated in the write domain when the local Gray pointer matches the synchronized read pointer with the two most significant bits (MSB & MSB-1) inverted to account for pointer wrap-around.
* Assertion-Based Verification (ABV): Features embedded procedural assertions to catch write-overflow and read-underflow boundary violations instantly during simulation runs.

---

## Toolchain & Tech Stack

* Hardware Description Language: SystemVerilog (IEEE 1800)
* Simulation Engine: Icarus Verilog (iverilog -g2012)
* Execution & Verification: vvp runtime engine
* Waveform Trace Analysis: GTKWave (fifo_trace.vcd)

---

## Directory Structure

async_fifo.sv       # Parameterized Asynchronous FIFO RTL & CDC Synchronizers
tb_async_fifo.sv    # Dual-clock asynchronous simulation testbench
README.md           # Architecture and verification documentation
fifo_trace.vcd      # Simulation waveform output trace

---

## Build and Verification Guide

### 1. Compile SystemVerilog Modules
iverilog -g2012 -o fifo_sim async_fifo.sv tb_async_fifo.sv

### 2. Execute Testbench Simulation
vvp fifo_sim

### 3. Waveform Visualization
gtkwave fifo_trace.vcd
