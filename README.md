# Optimized GF(2¹²⁸) Multiplier for AES-GCM

**Karatsuba Decomposition and Microarchitectural Pipelining**

> M.Tech VLSI Design Project — VIT Vellore  
> **Syed Faheem** (25MVD0030)  
> Under the guidance of **Dr. Abhishek Narayan Tripathi**, Associate Professor, Dept. of Micro and Nano Electronics

---

## Overview

AES-GCM (Galois/Counter Mode) is the dominant authenticated encryption standard used in TLS/SSL, VPNs, and cloud data centers. Its authentication path relies on the GHASH function, whose core operation is multiplication in the binary extension field GF(2¹²⁸). This project designs, implements, and compares three RTL architectures for this multiplier — progressing from a naive baseline to a Karatsuba-decomposed design to a microarchitecturally pipelined implementation — and evaluates each against area, timing, power, and performance-density metrics using the SAED 14nm RVT standard cell library.

---

## Table of Contents

- [Background](#background)
- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Design Details](#design-details)
  - [Architecture 1 — Reduced Naive GF(2¹²⁸)](#architecture-1--reduced-naive-gf2128)
  - [Architecture 2 — Partial Karatsuba (Combinational)](#architecture-2--partial-karatsuba-combinational)
  - [Architecture 3 — Karatsuba with Internal Pipelining](#architecture-3--karatsuba-with-internal-pipelining)
- [Results](#results)
  - [Area & Structure](#area--structure)
  - [Timing & Throughput](#timing--throughput)
  - [Power & Efficiency](#power--efficiency)
- [Simulation](#simulation)
- [Synthesis Setup](#synthesis-setup)
- [References](#references)

---

## Background

Multiplication in GF(2¹²⁸) operates over binary polynomials modulo the AES-GCM irreducible polynomial:

```
x¹²⁸ + x⁷ + x² + x + 1
```

All additions are XOR operations (no carry). A naive 128×128 polynomial multiplier generates a 256-bit intermediate product via AND-plane partial product generation followed by an XOR reduction tree, and then reduces the result modulo the field polynomial. While correct, this results in a long combinational critical path that limits achievable clock frequency.

This project demonstrates that **microarchitectural pipelining**, applied within the Karatsuba-decomposed structure, yields greater frequency scaling than algorithmic optimization alone.

---

## Architecture Overview

![GF(2¹²⁸) Karatsuba Block Diagram](reports/gf128.png)

```
GF(2¹²⁸) Multiplier
│
├── [Arch 1] Naive: Full 128×128 AND-plane + XOR tree + Reduction
│
├── [Arch 2] Karatsuba (Combinational):
│     128-bit inputs split → (A₁, A₀), (B₁, B₀)
│     3 × GF(2⁶⁴) multipliers:
│       P0 = A₀ × B₀
│       P2 = A₁ × B₁
│       P1 = (A₀ ⊕ A₁)(B₀ ⊕ B₁)
│     → Karatsuba Recombination (XOR + shifts)
│     → AES-GCM Reduction mod (x¹²⁸ + x⁷ + x² + x + 1)
│     → 128-bit result
│
└── [Arch 3] Karatsuba + Internal Pipelining:
      Same decomposition, but GF(2⁶⁴) blocks are 2-stage pipelined:
        Stage 1: Partial product generation (AND plane)
        Stage 2: XOR compression tree
      + Stage 3: Karatsuba recombination + final reduction
      Total latency: 3 cycles
```

---

## Repository Structure

```
set_project/
│
├── verilog/
│   ├── gf128_naive.v                      # 128×128 polynomial multiplier (AND + XOR tree)
│   ├── gf128_naive_reduced.v              # Naive multiplier + AES-GCM reduction (Architecture 1)
│   ├── gf128_reduce_opt.v                 # Optimized modular reduction block
│   ├── gf64_mul.v                         # Combinational 64×64 GF polynomial multiplier
│   ├── gf128_karatsuba.v                  # Partial Karatsuba multiplier — combinational (Architecture 2)
│   ├── gf128_mul_reduced.v                # Karatsuba multiplier with reduction
│   ├── gf64_mul_pipe2.v                   # 2-stage pipelined GF(2⁶⁴) multiplier
│   ├── gf128_karatsuba_pipe_gf64.v        # 3-stage pipelined Karatsuba multiplier (Architecture 3)
│   │
│   ├── tb_gf128_naive.v                   # Testbench: naive multiplier
│   ├── tb_gf128_mul_reduced.v             # Testbench: naive with reduction
│   ├── tb_gf64_mul.v                      # Testbench: 64-bit combinational multiplier
│   ├── tb_gf64_pipe2.v                    # Testbench: 64-bit pipelined multiplier
│   ├── tb_gf128_compare.v                 # Testbench: compare naive vs Karatsuba outputs
│   └── tb_gf128_naive_vs_kara_reduced.v   # Testbench: full comparison across architectures
│
└── reports/
    ├── naive_reduced_area.rpt.pdf
    ├── naive_reduced_timing.rpt.pdf
    ├── naive_reduced_power.rpt.pdf
    ├── naive_reduced_qor.rpt.pdf
    ├── kara_reduced_area.rpt.pdf
    ├── kara_reduced_timing.rpt.pdf
    ├── kara_reduced_power.rpt.pdf
    ├── kara_reduced_qor.rpt.pdf
    ├── kara_pipe_area.rpt.pdf
    ├── kara_pipe_timing.rpt.pdf
    ├── kara_pipe_power.rpt.pdf
    ├── kara_pipe_qor.rpt.pdf
    └── *.png                              # Waveform screenshots
```

---

## Design Details

### Architecture 1 — Reduced Naive GF(2¹²⁸)

**Module:** `gf128_naive_reduced` (top) → `gf128_naive` + `gf128_reduce_opt`

A straightforward 128×128 binary polynomial multiplier. The AND plane generates all 128² partial products; the XOR reduction tree accumulates them into a 256-bit intermediate product, which is then reduced modulo the AES-GCM field polynomial.

- Fully combinational, 1-cycle latency
- 12 logic levels on critical path
- Serves as the performance baseline

---

### Architecture 2 — Partial Karatsuba (Combinational)

**Module:** `gf128_mul_reduced` → `gf128_karatsuba` + `gf128_reduce_opt`

Applies the Karatsuba identity at the 128-bit level only, splitting each operand into 64-bit halves and computing three 64×64 sub-products (P0, P1, P2) using `gf64_mul`. The sub-products are recombined via XOR shifts and then reduced.

```
P0 = A_lo × B_lo
P2 = A_hi × B_hi
P1 = (A_lo ⊕ A_hi) × (B_lo ⊕ B_hi)

Product = P2·x¹²⁸ ⊕ (P0 ⊕ P1 ⊕ P2)·x⁶⁴ ⊕ P0
```

![GF(2⁶⁴) Multiplier Block](reports/gf64.png)

- Reduces sub-multiplication count from 4 to 3
- 11 logic levels, fully combinational (1-cycle latency)
- 19% area reduction over naive

**Key observation:** Algorithmic reduction alone gives only a marginal improvement in delay; frequency improvement is limited without pipelining.

---

### Architecture 3 — Karatsuba with Internal Pipelining

**Module:** `gf128_karatsuba_pipe_gf64` → `gf64_mul_pipe2` (×3)

Pipeline registers are inserted inside each `gf64_mul` block, splitting the 64×64 multiplier into two stages (partial product generation → XOR compression). The recombination and final AES-GCM reduction form a third pipeline stage.

```
Stage 1 (Cycle 1):  Partial product (AND plane) generation inside GF(2⁶⁴) blocks
Stage 2 (Cycle 2):  XOR compression tree inside GF(2⁶⁴) blocks
Stage 3 (Cycle 3):  Karatsuba recombination + modular reduction
```

![Pipelined GF(2⁶⁴) Internal Structure](reports/internal64.png)

- Total latency: 3 cycles
- 9 logic levels on critical path
- Supports `valid_in` / `valid_out` handshake signals
- Throughput matches Fmax (one result per cycle at full rate)

---

## Results

### Area & Structure

| Metric               | Naive   | Karatsuba | Pipeline |
|----------------------|---------|-----------|----------|
| Total Area (µm²)     | 33,080  | 26,747    | 26,756   |
| Combinational Cells  | 23,640  | 17,505    | 19,010   |
| Sequential Cells     | 0       | 0         | 1,215    |
| Logic Levels         | 12      | 11        | 9        |

> Karatsuba achieves a **19% area reduction** over the naive baseline. Pipelining adds only 1,215 flip-flops (sequential cells) with negligible area overhead relative to the Karatsuba combinational design.

---

### Timing & Throughput

| Metric                  | Naive | Karatsuba | Pipeline |
|-------------------------|-------|-----------|----------|
| Critical Path (ns)      | 4.40  | 4.20      | 2.23     |
| F_max (MHz)             | 238   | 250       | 448      |
| Latency (cycles)        | 1     | 1         | 3        |
| Throughput (Mops/s)     | 238   | 250       | 448      |

> Internal pipelining reduces the critical path by **47%** (4.40 ns → 2.23 ns) and achieves an **88% increase in maximum frequency** (238 → 448 MHz). Since the pipeline is fully utilized, throughput equals Fmax.

---

### Power & Efficiency

| Metric                         | Naive   | Karatsuba | Pipeline |
|--------------------------------|---------|-----------|----------|
| Dynamic Power (mW)             | 3.864   | 3.156     | 7.816    |
| Leakage (µW)                   | 425     | 315       | 315      |
| Performance/Area (MHz/µm²)     | 0.00719 | 0.00934   | 0.0167   |
| Performance/Watt (MHz/mW)      | 61.6    | 79.2      | 57.3     |

> The pipelined architecture's dynamic power increase (due to higher switching activity at 448 MHz) is a trade-off for a **132% improvement in performance density** (MHz/µm²). The Karatsuba combinational design offers the best performance-per-watt figure among the three.

---

## Simulation

All testbenches are written in Verilog and can be run with any standard simulator (Icarus Verilog, ModelSim, VCS, etc.).

**Combinational architectures (Arch 1 & 2):**
```bash
# Example using Icarus Verilog
iverilog -o sim_naive tb_gf128_naive.v gf128_naive.v
vvp sim_naive

iverilog -o sim_compare tb_gf128_compare.v gf128_naive.v gf128_karatsuba.v gf64_mul.v
vvp sim_compare

iverilog -o sim_kara_vs_naive tb_gf128_naive_vs_kara_reduced.v \
    gf128_naive_reduced.v gf128_naive.v gf128_reduce_opt.v \
    gf128_mul_reduced.v gf128_karatsuba.v gf64_mul.v
vvp sim_kara_vs_naive
```

**Pipelined architecture (Arch 3):**
```bash
iverilog -o sim_pipe tb_gf64_pipe2.v gf64_mul_pipe2.v
vvp sim_pipe
```

The comparison testbenches (`tb_gf128_compare.v`, `tb_gf128_naive_vs_kara_reduced.v`) apply randomized and edge-case input vectors to both architectures simultaneously and flag any output mismatches.

---

## Synthesis Setup

All three architectures were synthesized under identical conditions for a fair comparison:

- **Tool:** Synopsys Design Compiler
- **Target Library:** SAED 14nm RVT standard cell library
- **Timing Constraints:** Same across all three designs (no manual retiming)
- **Wireload Model & Operating Conditions:** Identical
- **Synthesis reports** (area, timing, power, QoR) are provided in the `reports/` directory as PDFs

---

## Key Takeaway

> **Microarchitectural optimization (internal pipelining) provides greater frequency scaling than algorithmic optimization (Karatsuba decomposition) alone.**  
> The best overall design combines both: Karatsuba reduces area and submodule complexity, while internal pipelining within the GF(2⁶⁴) blocks unlocks near-2× frequency improvement.

---

## References

1. NIST, *Recommendation for Block Cipher Modes of Operation: GCM and GMAC*, SP 800-38D, 2007.
2. NIST, *Advanced Encryption Standard (AES)*, FIPS 197, 2001.
3. A. A. Karatsuba, "The Complexity of Computations," *Proc. Steklov Inst. Math.*, 1995.
4. M. Wegman and J. Carter, "New Hash Functions and Their Use in Authentication," *JCSS*, 1981.
5. SAED 14nm RVT Standard Cell Library Documentation.
6. Synopsys Design Compiler User Guide.

---

*M.Tech VLSI Design — VIT Vellore | Under the guidance of Dr. Abhishek Narayan Tripathi*
