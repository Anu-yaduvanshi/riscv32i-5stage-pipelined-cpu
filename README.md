# 5-Stage Pipelined RV32I RISC-V Processor Core

A fully verified, synthesizable 32-bit RISC-V (RV32I base ISA) processor designed from scratch in SystemVerilog. The microarchitecture features a classic 5-stage pipeline (IF, ID, EX, MEM, WB) with hardware hazard resolution, full forwarding, load-use stall detection, control hazard flushing, SystemVerilog Assertions (SVA), and hardware performance profiling counters.

---

## Architecture Specifications

- **Instruction Set Architecture (ISA):** RISC-V RV32I Base Integer Instruction Set (Word-aligned 32-bit instructions).
- **Microarchitecture:** 5-Stage Scalar In-Order Pipeline:
  - **IF (Instruction Fetch):** Program Counter with enable control and 32-bit instruction memory interface.
  - **ID (Instruction Decode):** Dual asynchronous read-port register file ($x0$ hardwired to 0), sign-extension immediate generator (I, S, B, U, J types), and control unit.
  - **EX (Execute):** 32-bit ALU supporting 10 arithmetic/logic operations, branch target computation, and ALU operand multiplexing.
  - **MEM (Data Memory):** Synchronous write and combinational read data memory interface.
  - **WB (Writeback):** Result multiplexing (ALU result, memory read data) with register retirement.
- **Hazard Handling & Mitigation:**
  - **Forwarding Unit (RAW):** Resolves EX-to-EX and MEM-to-EX arithmetic dependencies with priority routing.
  - **Hazard Detection Unit (Load-Use):** Identifies load-use dependencies in ID stage; freezes PC and IF/ID while injecting a 1-cycle bubble (NOP) into ID/EX.
  - **Control Hazard / Branch Unit:** Resolves branches in EX stage; redirects PC to target and executes a 2-cycle flush of speculative instructions in IF and ID.
- **Verification & Profiling:**
  - Passive SVA monitor asserting architectural invariants ($x0$ integrity, PC word alignment).
  - Hardware performance counters profiling Total Cycles, Instructions Retired, Stall Cycles, Flush Penalties, CPI, and IPC.

---

## Datapath Block Diagram

   [IF]              [ID]             [EX]             [MEM]             [WB]
 +--------+       +----------+       +--------+        +---------+       +--------+
 | PC Reg | IF/ID | Decode & |ID/EX  |  ALU & |EX/MEM  |Data Mem |MEM/WB |RegFile |
 |& I-Mem |======>| RegFile  |======>| Branch |=======>|(Load/   |======>| Write  |
 |        |       |          |       | Forward|        | Store)  |       |(Retire)|
 +--------+       +----------+       +--------+        +---------+       +--------+
     ^                ^                |              |             |
     |                |                |              |             |
     +-- Stall <------+-- Hazard Unit -+              |             |
     |   (pc_en, if_id_en) [Load-Use]  |              |             |
     |                                 |              |             |
     +-- Target & Flush <--------------+              |             |
         (branch_taken)                |              |             |
                                       +<== Forward ==+=============+
                                            (forwardA, forwardB)
 
## Directory Structure


CPU/
├── rtl/                        # Synthesizable SystemVerilog Core Logic
│   ├── pc.sv                   # Program Counter Register with synchronous enable
│   ├── instruction_memory.sv   # Combinational Read ROM (Instruction Store)
│   ├── register_file.sv        # 32x32 Register File (Dual asynchronous read)
│   ├── immediate_generator.sv  # Sign-extension logic for I, S, B, U, J types
│   ├── alu.sv                  # 10-Operation Combinational ALU
│   ├── control_unit.sv         # Central Opcode & Funct Decoder
│   ├── data_memory.sv          # Synchronous Write / Combinational Read RAM
│   ├── if_id.sv                # Fetch -> Decode Pipeline Register
│   ├── id_ex.sv                # Decode -> Execute Pipeline Register
│   ├── ex_mem.sv               # Execute -> Memory Pipeline Register
│   ├── mem_wb.sv               # Memory -> Writeback Pipeline Register
│   ├── forwarding_unit.sv      # RAW Data Hazard Forwarding Matrix
│   ├── hazard_unit.sv          # Load-Use Dependency Stall Detector
│   ├── branch_unit.sv          # Branch Comparator & Target Validator
│   ├── cpu.sv                  # Integrated 5-Stage Pipelined Processor
│   └── cpu_top.sv              # Synthesis Boundary Top-Level Wrapper
├── tb/                         # Verification Testbenches & Monitors
│   ├── cpu_pipeline_tb.sv      # Linear Data Hazards & Stall Testbench
│   ├── cpu_branch_tb.sv        # Control Hazard Branch Flush Testbench
│   ├── cpu_sva_tb.sv           # Assertion-Based Verification Testbench
│   ├── cpu_monitor.sv          # Architectural Invariant Checker & Tracer
│   ├── perf_monitor.sv         # Hardware Performance Profiler (CPI/IPC)
│   └── cpu_benchmark_tb.sv     # Comprehensive Mixed-Workload Testbench
├── programs/                   # Assembled Instruction Memory Images
│   ├── pipeline_test.hex       # RAW dependency and load-use test program
│   ├── branch_test.hex         # Control flow branch/jump validation program
│   └── benchmark.hex           # Comprehensive multi-instruction benchmark
├── scripts/                    # Synthesis Constraints and Tool Scripts
│   ├── cpu_constraints.sdc     # Synopsys Design Constraints (100 MHz target)
│   └── synth_yosys.tcl         # Yosys RTL Synthesis & Mapping Script
├── sim/                        # Simulation Executables (.vvp, .out)
├── waves/                      # GTKWave Value Change Dump (VCD) Traces
└── README.md                   # Technical Documentation & Specification


 PHASE 18: MIXED WORKLOAD VERIFICATION RESULTS    
x1 (Expected 10)  : 10
x2 (Expected 10)  : 10
x3 (Fwd, Exp 20)  : 20
x4 (Load, Exp 20) : 20
x5 (Stall, Exp 30): 30
x6 (Target, Exp 42): 42
x7 (Trap, Exp 0)  : 0 [FLUSHED!]
[PASS] Mixed Workload Benchmark Executed Successfully!
       PIPELINE PERFORMANCE PROFILING REPORT      
 Total Clock Cycles       : 25
 Instructions Retired     : 6
 Load-Use Stall Cycles    : 1
 Branch Penalty Cycles    : 2
 Measured CPI             : 4.17
 Measured IPC             : 0.24
