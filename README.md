# Parameterized Asynchronous FIFO with ABV, CRV, and Functional Coverage

A high-performance, parameterized Asynchronous FIFO (First-In, First-Out) architecture written in SystemVerilog (IEEE 1800). This design safely transfers multi-bit data across unsynchronized Clock Domain Crossings (CDC) without risking metastability, data corruption, or multi-bit bus skew errors.

---

## Architecture & Verification Engineering

Modern System-on-Chip (SoC) architectures require reliable communication between independent clock domains. This module implements production-grade hardware mitigations and verification techniques:

* Dual-Clock Domain Isolation: Write domain (wclk) and Read domain (rclk) operate completely asynchronously with independent frequency and phase relationships.
* Gray Code Pointer Conversion: Binary read/write pointers are converted to Gray code before crossing clock boundaries, guaranteeing that only a single bit toggles per clock transition.
* 2-Stage Flip-Flop Synchronizers: Cross-domain pointers are synchronized via cascaded 2-flop synchronizer pipelines (wq2_rptr, rq2_wptr) to allow metastable signals to settle.
* Assertion-Based Verification (ABV): Features embedded procedural assertions to catch write-overflow (wfull violation) and read-underflow (rempty violation) boundary conditions instantly during simulation.
* Constrained-Random Verification (CRV): Advanced testbench applies randomized bursts of write/read control pulses and dynamic data payloads to stress corner-case state transitions.
* Functional Coverage Tracking: Real-time metrics track full-hit, empty-hit, and transaction boundary coverage across clock domains.

---

## Toolchain & Tech Stack

* Language: SystemVerilog (IEEE 1800)
* Simulation Engine: Icarus Verilog (iverilog -g2012)
* Execution & Verification: vvp runtime engine
* Waveform Trace Analysis: GTKWave (fifo_crv_trace.vcd)

---

## Directory Structure

async_fifo.sv            # Parameterized Asynchronous FIFO RTL & CDC Synchronizers
tb_async_fifo.sv        # Dual-clock basic directed simulation testbench
tb_crv_coverage_fifo.sv  # Constrained-Random Testbench & Functional Coverage Tracking
README.md                # Architecture and verification documentation
fifo_crv_trace.vcd       # Simulation waveform output trace

---

## Build and Verification Guide

### 1. Compile SystemVerilog Modules
iverilog -g2012 -o crv_sim async_fifo.sv tb_crv_coverage_fifo.sv

### 2. Run CRV & Coverage Simulation
vvp crv_sim

### 3. Waveform Visualization
gtkwave fifo_crv_trace.vcd
