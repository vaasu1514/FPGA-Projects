# Booth Multiplier (FPGA Implementation)

This project implements an **8-bit signed Booth Multiplier** on the **Basys-3 FPGA board** using **Verilog HDL**.  
The design follows a **clean controller–datapath architecture** and supports both **manual step-by-step execution** and **automatic operation** for educational and verification purposes.

---

## Overview

Booth’s algorithm is used to efficiently perform signed multiplication by reducing the number of addition and subtraction operations.  
This implementation allows the algorithm to be observed **cycle-by-cycle** or executed automatically at a slower clock rate suitable for FPGA demonstration.

---

## Architecture

The design is modular and hierarchical:

- **Top Module (`booth_top.v`)**
  - Integrates datapath, controller, debounce logic, and auto-step clock
  - Interfaces with Basys-3 switches, buttons, and LEDs

- **Datapath (`booth_datapath.v`)**
  - Registers: Accumulator **A (N+1 bits)**, Multiplier **Q**, and **Q-1**
  - Sign-extended multiplicand **M**
  - Arithmetic unit supporting add/subtract operations
  - Arithmetic right shift of `{A, Q, Q-1}`
  - Iteration counter with zero detection

- **Controller (`booth_controller.v`)**
  - FSM controlling Booth algorithm flow
  - States: `IDLE → READY → DECIDE → ADD/SUB → SHIFT → CHECK → FIN`
  - Generates control signals for add/subtract, shift, and load operations

- **Debounce Module (`debounce.v`)**
  - Converts noisy push-button inputs into clean single-cycle pulses
  - Used for load, step, auto toggle, and reset buttons

---

## Features

- 8-bit signed Booth multiplication (parameterizable via `N`)
- Controller–datapath separation
- Manual **single-step execution** using push buttons
- Automatic execution using an internal clock divider (~6 Hz)
- Arithmetic right shifting with sign preservation
- Real-time visualization of intermediate results on LEDs
- Clean synchronous design suitable for FPGA synthesis

---

## Input & Output Mapping (Basys-3)

### Inputs
- **Switches**
  - `SW[15:8]` → Multiplicand (M)
  - `SW[7:0]`  → Multiplier (Q)
- **Buttons**
  - `BTN_C` → Load operands
  - `BTN_U` → Manual step
  - `BTN_L` → Toggle auto mode
  - `BTN_R` → Reset

### Outputs
- `LED[15:8]` → Accumulator A (lower 8 bits)
- `LED[7:0]`  → Multiplier Q

---

## Operation Modes

### Manual Mode
- Each press of the **step button** advances the algorithm by one Booth iteration
- Useful for understanding intermediate states

### Automatic Mode
- Algorithm runs automatically using a divided clock
- Suitable for demonstration without continuous button presses



