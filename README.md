# SET_PROJECT

# Optimized GF(2^128) Multiplier for AES-GCM  
### Naive + Karatsuba Implementations in Verilog (FPGA-Ready)

This repository contains a hardware-oriented implementation of **Galois Field (GF(2^128)) multipliers**, targeting the GHASH component of the **AES-GCM** cryptographic algorithm.  
The project includes both a **baseline naive multiplier** and an **optimized Karatsuba-based multiplier**, along with self-checking testbenches.

## 🚀 Project Goals
- Implement a correct **GF(2^128)** multiplication engine for AES-GCM.  
- Compare:
  - **Naive polynomial multiplication**
  - **Karatsuba multiplication**
- Optimize for:
  - **Low latency**
  - **Reduced switching activity / dynamic power**
  - **Higher throughput (optional pipelining)**
- Validate all modules using **self-checking testbenches** in ModelSim/Questa.

---

## 📌 Repository Structure
├── gf64_mul.v # 64×64 polynomial multiplier (GF(2))
├── tb_gf64_mul.v # Self-checking testbench for gf64_mul
├── gf128_naive.v # (Coming soon) naive 128×128 GF multiplier
├── gf128_karatsuba.v # (Coming soon) optimized Karatsuba GF multiplier
├── tb_gf128_compare.v # (Coming soon) naive vs Karatsuba verification
└── README.md


---

## 🧠 Background  
AES-GCM requires multiplication in the finite field **GF(2^128)** using the irreducible polynomial:

\[
P(x) = x^{128} + x^7 + x^2 + x + 1
\]

The multiplication itself has two steps:

1. **Polynomial multiplication** over GF(2)  
   - bitwise AND → multiplication  
   - XOR → addition (mod 2)  

2. **Modulo reduction** using AES-GCM polynomial  

This project implements Step 1 for both naive and Karatsuba methods and will integrate Step 2 in the optimized design.

---

## 🧩 Implemented Modules

### ✔ `gf64_mul.v` — 64×64 Polynomial Multiplier  
- Pure combinational logic  
- Implements shift-and-XOR polynomial multiply  
- Output is full 128-bit product (no reduction)  
- Acts as the building block for Karatsuba 128-bit multiplier  

### ✔ `tb_gf64_mul.v` — Self-Checking Testbench  
- Runs fixed tests  
- Runs 2000 randomized vectors  
- Compares DUT against internal reference model  
- Reports mismatches with full values  

---

## 🛠️ How to Run (ModelSim/Questa)

### Step 1: Create library
vlib work
vmap work work

### Step 2: Compile design + testbench
vlog gf64_mul.v
vlog tb_gf64_mul.v

### Step 3: Simulate
vsim tb_gf64_mul
run -all

Expected output:
All tests passed (2000 random vectors).

---

## 📊 Next Steps  
Planned additions to this repository:

- [ ] `gf128_naive.v` — slow but correct reference multiplier  
- [ ] `gf128_karatsuba.v` — optimized multiplier using 3×gf64 blocks  
- [ ] Modulo-P(x) reduction logic for AES-GCM  
- [ ] Optional pipelining stages  
- [ ] FPGA synthesis (Cyclone IV / Zynq optional)  
- [ ] Power and latency comparison between methods  

---

## 👤 Author  
**Syed Faheem**  
M.Tech VLSI Design  
VIT Vellore

