# Hexadecimal Keypad Interface (Basys-3 FPGA)

## Overview
This project implements a **4×4 hexadecimal keypad interface** on the **Basys-3 FPGA board** using Verilog HDL.  
The design scans keypad rows and columns, decodes key presses into a **4-bit hexadecimal code**, and displays the result on onboard LEDs.

The implementation focuses on **reliable hardware interfacing**, including clock-domain synchronization and a finite-state-machine–based scanning mechanism.

---

## Hardware Platform
- **FPGA Board:** Digilent Basys-3 (Artix-7)
- **Clock:** 100 MHz onboard oscillator
- **Inputs:**  
  - 4×4 matrix keypad (ROW[3:0], COL[3:0])  
  - Center push button (`btnC`) used as reset
- **Outputs:**  
  - LEDs to display the detected hexadecimal key  
  - Valid signal indicator LED

---

## Design Architecture

### 1. Top Module (`top_keypad_basys3_nodebounce`)
- Integrates all submodules.
- Connects keypad rows and columns to the scanner logic.
- Displays the decoded 4-bit key value on LEDs.
- Uses a synchronized reset derived from the onboard push button.
- This version operates **without key debounce** to clearly demonstrate raw keypad scanning behavior.

---

### 2. Row Signal Synchronizer
- A two-stage flip-flop synchronizer is used on the OR-combined row inputs.
- Prevents **metastability** when asynchronous keypad signals enter the FPGA clock domain.
- Ensures stable detection of key press events before scanning begins.

---

### 3. Keypad Scanner (FSM-Based)
- Uses a **finite state machine (FSM)** to sequentially drive each column line.
- Reads the row lines to detect which key is pressed.
- Generates:
  - A **4-bit hexadecimal code** corresponding to the pressed key
  - A **valid signal** while a key press is detected
- Scanning continues until the key is released, preventing repeated false detections.

---

### 4. Hexadecimal Key Mapping
- Each key press is decoded based on the active row and column combination.
- Supports all **16 hexadecimal keys (0–F)**.
- Mapping is implemented using combinational logic for fast decoding.

---

### 5. Optional Debounce Module
- A parameterized debounce module is included for future integration.
- Designed for mechanical key stabilization using a counter-based approach.
- Can be enabled if stable, single-pulse key detection is required.

---

## Key Features
- FSM-based keypad scanning
- Metastability-safe input synchronization
- Real-time hexadecimal key decoding
- Modular Verilog design suitable for extension
- Compatible with Basys-3 hardware constraints

---

## File Structure

