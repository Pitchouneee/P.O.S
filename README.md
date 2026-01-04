# Minimal x86 Boot Sector (BIOS, 16-bit Real Mode)

This project contains a **minimal x86 boot sector** written in **16-bit x86 assembly**, meant for learning.
It demonstrates how a BIOS loads and executes the first sector of a bootable device, how to print text using BIOS interrupts, and introduces fundamental system concepts like the Stack and memory addressing.

---

## Part 1: How BIOS booting works (classic PC)

On a classic BIOS-based x86 system, the boot process is roughly:

1. The BIOS searches for a bootable device (disk, USB drive, etc.).
2. It **reads the very first sector** of that device (**512 bytes**, LBA 0).
3. It copies those 512 bytes into RAM at **0x0000:0x7C00** (often written simply as **0x7C00**).
4. The CPU jumps to that address and starts executing the code in **16-bit real mode**.

A valid boot sector must end with the boot signature **0xAA55** (last 2 bytes). Without it, the BIOS typically refuses to boot.

---

## Part 2: Core concepts (the basics - v1)

### 1. Real mode (16-bit)

At power-on, the CPU starts in **real mode**:

* **16-bit registers**: AX, BX, CX, DX, SP, BP, SI, DI
* Memory uses **segment:offset** addressing

  * physical address = `segment × 16 + offset`
  * example: `0x0000:0x7C00 → 0x0000 × 16 + 0x7C00 = 0x7C00`

---

### 2. AX, AH, and AL

In x86:

* `AX` is a **16-bit** register
* It can be accessed as two **8-bit** halves:

  * `AH` = high byte (bits 15–8)
  * `AL` = low byte (bits 7–0)

Example:

* `mov ah, 0x0E` selects a BIOS function
* `mov al, 'P'` loads the ASCII code for `P`

At that point `AX` is `0x0E??`, where `??` depends on `AL`.

---

### 3. BIOS interrupts (INT 0x10)

In real mode, BIOS services are available through **software interrupts**.

`INT 0x10` is the **BIOS video interrupt**.
When `AH = 0x0E`, it selects **teletype output**, which:

* prints the character in `AL`
* advances the cursor
* scrolls the screen when needed

Example:

```asm
mov ah, 0x0e
mov al, 'X'
int 0x10
```

This prints `X`.

---

## Part 3: Advanced concepts (The stack & functions - v2)

This section covers the new theory introduced in `boot-v2.asm`, which allows for cleaner code using strings and subroutines.

### 1. The stack (BP & SP)

To use functions (subroutines), the CPU needs a place to remember "where to return to". This is the **Stack**. It operates on a LIFO basis (Last In, First Out).

* **SP (Stack Pointer):** Points to the top of the stack
* **BP (Base Pointer):** Used as a reference point for the stack frame

In `boot-v2.asm`, we initialize the stack safely away from our code:

```asm
mov bp, 0x8000  ; Set the base of the stack to 0x8000
mov sp, bp      ; Initialize the stack pointer (empty stack)
```

*Why 0x8000?* Our code is at `0x7C00`. The stack grows *downwards* (towards lower addresses). Placing it at `0x8000` ensures it doesn't overwrite our boot sector code.

### 2. Pointers & Strings (BX)

In C, you use pointers. In Assembly, we use registers like `BX` to hold memory addresses.

* `mov bx, welcome_msg`: Loads the **address** of the string into BX
* `mov al, [bx]`: Reads the **value** (character) at the address contained in BX

We use **Null-Terminated Strings** (like in C). We define strings ending with `0`:

```asm
welcome_msg: db 'Welcome...', 0
```

The print loop continues until it sees a `0`.

### 3. Functions (CALL & RET)

* `call print_str`: Pushes the address of the next instruction onto the stack and jumps to `print_str`
* `ret`: Pops the return address from the stack and jumps back to it

We also use `pusha` and `popa` inside functions to save and restore all general-purpose registers, ensuring the function doesn't mess up the state of the main program.

The memory map:

```markdown
0xFFFF  +------------------+
        |                  |
        | ...              |
0x8000  +------------------+ <--- Base of the Stack (BP)
        | STACK (Grows     |      (SP goes down on PUSH)
        | downward)        |      (SP goes up on POP)
        |                  |
        v                  v
        |                  |
0x7E00  +------------------+ <--- Theoretical end of our sector (512 bytes)
        | Boot Sector Code |
        |                  |
0x7C00  +------------------+ <--- Start of the code (ORG 0x7C00)
        | ...              |
0x0000  +------------------+
```

---

## Setup (WSL / Ubuntu)

These steps match a typical **WSL (Ubuntu)** setup.

### Step 1 — Update WSL packages

```bash
sudo apt update && sudo apt upgrade
```

### Step 2 — Install compiler & assembler tools

```bash
sudo apt install build-essential nasm gcc-multilib
```

### Step 3 — Install QEMU (x86 emulator)

```bash
sudo apt install qemu-system-x86
```

### Check-up (versions)

```bash
nasm --version
gcc --version
qemu-system-i386 --version
```

---

## Build

The boot sector is assembled as a **flat binary** (raw 512-byte sector).

### Build V1

```bash
nasm -f bin boot-v1.asm -o boot.bin

```

### Build V2

```bash
nasm -f bin boot-v2.asm -o boot.bin

```

---

## Run (QEMU)

Boot the raw sector directly in QEMU:

```bash
qemu-system-i386 boot.bin
```

You should see:

```
Welcome on the OS better than Windows
P.O.S
```

---

## Educational scope

This project is intentionally minimal. It does **not**:

* Switch to protected mode or long mode.
* Load a kernel from disk (it just stays in the boot sector).

It demonstrates:

* BIOS boot sector structure (512 bytes + signature).
* Printing characters using BIOS `int 0x10`.
* (v2) Managing the stack and register pointers.

## Notes / references

* OSDev Wiki (excellent learning resource): [https://wiki.osdev.org/Main_Page](https://wiki.osdev.org/Main_Page)