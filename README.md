# Parameterized Asynchronous FIFO with Assertion-Based Verification (ABV)

A multi-channel Asynchronous FIFO (First-In, First-Out) design in SystemVerilog engineered to safely transfer data across unsynchronized Clock Domain Crossings (CDC). This architecture utilizes 2-stage flip-flop synchronizers combined with Gray code pointer conversion to eliminate metastability risks and multi-bit bus-skew errors.

---

## 🏛️ Architecture & CDC Logic

* **Write Domain (`wclk`):** Operates on a high-speed write clock (e.g., 100 MHz), driving data bursts into dual-port memory arrays.
* **Read Domain (`rclk`):** Operates on an asynchronous read clock (e.g., 40 MHz), reading sequential data independently.
* **2-Flop Synchronizers:** Cross-synchronizes binary pointers between unsynchronized clock boundaries to prevent metastability.
* **Gray Code Pointer Conversion:** Converts binary write and read pointers into Gray code prior to synchronization, ensuring only a single bit changes per clock edge to prevent bus-skew timing errors.
* **Full/Empty Detection:** Evaluates FIFO boundary status flags in real-time across separate clock domains.
* **Assertion-Based Verification (ABV):** Includes real-time assertion checks to flag write overflow and read underflow conditions.

---

## 🛠️ Toolchain & Specifications

* **Language:** SystemVerilog (IEEE 1800 standard)
* **Simulation Engine:** Icarus Verilog (`iverilog` -g2012)
* **Waveform Visualization:** GTKWave / Value Change Dump (`fifo_trace.vcd`)

---

## 🚀 How to Build and Run Simulation

### 1. Compile SystemVerilog Modules
```bash
iverilog -g2012 -o fifo_sim async_fifo.sv tb_async_fifo.sv
vvp fifo_sim
gtkwave fifo_trace.vcd

