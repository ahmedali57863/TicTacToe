<div align="center">
  <h1 align="center">🕹️ Retro Tic-Tac-Toe</h1>
  <p align="center">
    <strong>16-Bit Assembly State Machine & Heuristic AI Engine</strong>
  </p>
  
  <img src="https://img.shields.io/badge/Assembly-x86-00599C?style=for-the-badge&logo=c&logoColor=white" />
  <img src="https://img.shields.io/badge/Emulator-emu8086-D22128?style=for-the-badge&logo=windowsterminal&logoColor=white" />
  <img src="https://img.shields.io/badge/Interrupts-BIOS%20%2F%20DOS-20232A?style=for-the-badge&logo=gnubash&logoColor=61DAFB" />
</div>

<br />

## 🪐 Project Overview

**Retro Tic-Tac-Toe** is a fully functional, state-driven logic game engineered natively in 16-bit x86 Assembly Language. It demonstrates the practical application of low-level computer architecture, bridging the gap between theoretical hardware concepts and interactive software execution. 

Built entirely without external libraries, the system utilizes direct BIOS and DOS interrupts for real-time keystroke capture and ASCII rendering. The core logic is powered by a custom Heuristic AI bot that relies on strict stack preservation and cascading control structures (`CMP`/`JMP`) to execute automated, strategic opponent logic within the constraints of a segmented memory model.

<img width="802" height="448" alt="coal" src="https://github.com/user-attachments/assets/6555aa29-a61e-42f2-b2f9-fb8dc8c6d444" />

---

## ✨ Core Features

- 🧠 **Heuristic AI Engine:** Evaluates the board dynamically to execute a cascading priority ruleset (Detect Win $\rightarrow$ Block Player Threat $\rightarrow$ Secure Center $\rightarrow$ Secure Corners).
- 🎨 **BIOS-Level Hardware Rendering:** Bypasses standard DOS limitations by utilizing `INT 10h` video services to inject dynamic HEX color codes (Light Red / Light Green) into the ASCII console grid.
- 🛡️ **Dynamic State Management:** Maps the 3x3 game board to a continuous 9-byte data array in memory, featuring strict input validation to trap errors and prevent illegal memory overwriting.
- ⚙️ **Stack-Driven Modularity:** Utilizes a highly modular architecture of independent, callable procedures (`DRAW_BOARD`, `CHECK_WIN`), aggressively using `PUSH` and `POP` to prevent general-purpose register exhaustion.

---

## 🏗️ System Architecture

1. **Input & Validation Pipeline:** Human player triggers `INT 21h`. The Game Arbiter converts the ASCII input to a zero-indexed integer, calculates the memory offset (`[SI+BX]`), and validates the state.
2. **8-Way Algorithmic Checker:** The system iterates over the `win_lines` array, checking linear and diagonal contiguous memory slots for matching byte values.
3. **AI Response Node:** If the board yields no winner, control passes to the AI. The machine evaluates the board state against its hardcoded defense protocols and modifies the 9-byte array directly.
4. **Render Engine:** The main loop triggers the nested `CX` loops, redrawing the updated memory array to the console buffer.

---

## 👥 Team Contributions (Phase 2 CCA8)
This project was developed collaboratively, with strict module ownership to satisfy Complex Computing Problem (CCA) constraints:

- **Muhammad Ahmed:** Core Engine, BIOS `INT 10h` rendering loops, and DOS `INT 16h/21h` input handling.
- **Umama Khalid:** Data segment memory mapping and 8-way Array Validation / Check-Win algorithms.
- **Hamza Ali Kazmi:** Heuristic AI logic cascade, trap defense, and stack management.

---

## 🚀 Local Deployment

### 1. Prerequisites
To compile and run this project, you will need a 16-bit x86 emulator. We recommend **emu8086**.
- [Download emu8086](https://emu8086-microprocessor-emulator.en.softonic.com/) (Windows)

### 2. Clone the Repository
```bash
# Clone the repository to your local machine
git clone [https://github.com/YourUsername/TicTacToe.git](https://github.com/YourUsername/TicTacToe.git)
cd TicTacToe
