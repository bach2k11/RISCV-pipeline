# 🖥️ RISC-V Pipeline Processor (RV32I)

[![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](#)
[![Simulator](https://img.shields.io/badge/Simulator-Mentor_QuestaSim-green.svg)](#)
[![Architecture](https://img.shields.io/badge/Architecture-RV32I_5--Stage-orange.svg)](#)

A full-featured, 5-stage pipelined RISC-V (RV32I) processor implementation. This project includes a robust verification environment utilizing Mentor QuestaSim, SystemVerilog Assertions (SVA), and comprehensive Code Coverage tracking to ensure silicon-ready reliability.

## 📑 Table of Contents
1. [Overview](#-overview)
2. [Pipeline Architecture](#-pipeline-architecture)
3. [Supported Instructions](#-supported-instructions)
4. [Project Structure](#-project-structure)
5. [Getting Started](#-getting-started)
6. [Simulation & Verification](#-simulation--verification)
7. [Test Suites](#-test-suites)


## 📖 Overview
This repository contains the RTL design and verification suite for a 32-bit RISC-V processor. Designed for high throughput, the core handles data forwarding, hazard detection, and pipeline stalling natively in hardware, preventing data corruption during sequential assembly execution.

## 🏗️ Pipeline Architecture
The processor is built on a classic 5-stage pipeline model:
* **Instruction Fetch (IF):** Fetches the next instruction from instruction memory.
* **Instruction Decode (ID):** Decodes instructions, reads the register file, and resolves control hazards.
* **Execute (EX):** Performs ALU operations, calculates branch addresses, and manages data forwarding.
* **Memory Access (MEM):** Handles Read/Write operations to the data memory.
* **Write Back (WB):** Commits the final computed results back to the register file.



## 🌟 Supported Instructions
The core fully implements the RV32I Base Integer Instruction Set required for complex algorithms:
* **Arithmetic & Logical:** `add`, `addi`, `sub`, `and`, `andi`, `or`, `ori`, `xor`
* **Shifts:** `sll`, `slli`, `sra`
* **Comparisons:** `slt`, `slti`
* **Control Flow:** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `jal`
* **Upper Immediate:** `lui`, `auipc`
* **Memory Access:** `lw`, `sw`

## 📂 Project Structure
```text
├── docs/                   # Documentation and diagrams
├── rtl/                    # SystemVerilog source files for the processor
├── sim/
│   ├── tests/              # Assembly test programs (test.txt, etc.)
│   └── work/               # QuestaSim working directory and scripts
│       ├── qrun_bash.sh    # Main automation bash script
│      file
│       └── filelist_*.f    # Compilation file lists
└── README.md               # Project documentation
```

## 🚀 Getting Started

### Prerequisites
* **OS:** Linux x86_64 environment
* **Tools:** Mentor QuestaSim installed and added to your system `$PATH`

### Environment Setup
Navigate to the simulation working directory and source the provided bash script to initialize tool paths and command aliases:
```bash
cd sim/work
source qrun_bash.sh
```

## 💻 Simulation & Verification


### Compilation Commands
| Alias | Action Performed |
| :--- | :--- |
| `vlb` | Cleans the workspace, removes old logs, and recreates the `work` library. |
| `vlgr`| Compiles the RTL files (`filelist_com.f`, `filelist_rtl.f`) with coverage enabled. |
| `vlgt`| Compiles the Testbench files (`filelist_tb.f`, `filelist_vsim.f`). |
| `vlg` | Compiles both RTL and Testbench files automatically (`vlgr` + `vlgt`). |

### Simulation Commands
| Alias | Action Performed |
| :--- | :--- |
| `vsm` | Runs the simulation, evaluates SVAs (`-sva`), generates `coverage.ucdb`, and logs waves. |
| `vsm_opt`| Runs a high-speed simulation without GUI wave logging. |

### Debugging Commands
| Alias | Action Performed |
| :--- | :--- |
| `viw` | Opens the QuestaSim GUI to analyze the generated waveforms (`vsim.wlf`) using `wave.do`. |
| `viwcov`| Opens the QuestaSim coverage viewer to inspect `coverage.ucdb`. |

## 🧪 Test Suites
The processor is heavily verified against custom assembly programs compiled into machine code. 

* **TEST_1 (Basic Looping):** Validates arithmetic and PC branch-back mechanisms.
* **TEST_2 (Control Flow & Memory):** Tests nested branching and sequential memory load/store operations (e.g., writing `25` to address `100`).
* **TEST_3 (Exhaustive Branching):** Thoroughly exercises every branch condition (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`) against ALU flags.
* **TEST_4 (Advanced Execution):** Validates bitwise logic, shifts, PC-relative addressing (`auipc`), and upper immediates (`lui`).
* **TEST_5 (Bubble Sort):** A full sorting algorithm validating the processor's capability to manage array pointers, nested loops, memory swapping, and continuous hazard resolution.

