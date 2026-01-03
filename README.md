# Minimal x86 Boot Sector (BIOS, 16-bit Real Mode)

This project contains a **minimal x86 boot sector** written in **16-bit x86 assembly**, meant for learning.
It shows how a BIOS loads and executes the first sector of a bootable device and how to print text using BIOS interrupts.

The boot sector displays:

```
P.O.S
```

and then loops forever.

---

## How BIOS booting works (classic PC)

On a classic BIOS-based x86 system, the boot process is roughly:

1. The BIOS searches for a bootable device (disk, USB drive, etc.).
2. It **reads the very first sector** of that device (**512 bytes**, LBA 0).
3. It copies those 512 bytes into RAM at **0x0000:0x7C00** (often written simply as **0x7C00**).
4. The CPU jumps to that address and starts executing the code in **16-bit real mode**.

A valid boot sector must end with the boot signature **0xAA55** (last 2 bytes). Without it, the BIOS typically refuses to boot.

---

## Core concepts

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

## Build (assemble)

This boot sector is assembled as a **flat binary** (raw 512-byte sector):

```bash
nasm -f bin boot.asm -o boot.bin
```

---

## Run (QEMU)

Boot the raw sector directly in QEMU:

```bash
qemu-system-i386 boot.bin
```

You should see:

```
P.O.S
```

printed on the emulated screen.

---

## Notes / references

* OSDev Wiki (excellent learning resource):
  [https://wiki.osdev.org/Main_Page](https://wiki.osdev.org/Main_Page)

---

## Educational scope

This project is intentionally minimal. It does **not**:

* set up a stack
* initialize segment registers
* switch to protected mode or long mode

It only demonstrates:

* BIOS boot sector structure (512 bytes + signature)
* printing characters using BIOS `int 0x10` (AH = 0x0E)