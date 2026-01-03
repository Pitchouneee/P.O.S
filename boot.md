# Global context: what is this file?

This is a minimal **boot sector** written in **16-bit x86 assembly**.

When a “classic BIOS-based” PC starts:

1. The BIOS looks for a bootable device (disk, USB drive, etc.)
2. It **reads the very first sector** (512 bytes) of the device (LBA 0)
3. It copies these 512 bytes into RAM at address **0x0000:0x7C00** (often written simply as “0x7C00”)
4. It jumps to this address and executes the code in **real mode** (16-bit real mode)

This code displays `P.O.S` on the screen using the BIOS, then enters an infinite loop.

# Essential basic concepts

## 1. Real mode (16-bit)

At the very beginning, the CPU is in **real mode**:

- **16-bit registers** (AX, BX, CX, DX, SP, BP, SI, DI)
- memory addressing using **segment:offset**
    - physical address = `segment * 16 + offset`
    - example : `0x0000:0x7C00` → `0x0000 * 16 + 0x7C00 = 0x7C00`

## 2. AH / AL and AX registers

In x86 :

- `AX` is a 16-bit register
- it is split into two 8-bit registers:
    - `AH` = high byte (bits 15..8)
    - `AL` = low byte (bits 7..0)

Therefore:

- `mov ah, 0x0e` puts 0x0E into AH
- `mov al, 'P'` puts the ASCII code of P into AL

## 3. BIOS interrupts (int 0x10)

In real mode, BIOS services can be called using `int xx`.

`int 0x10` = **BIOS video services**.

Setting `AH=0x0E` selects the **teletype output** function:

- displays the character in `AL`
- advances the cursor
- handles scrolling, etc.

So the sequence:

- `mov ah, 0x0e`
- `mov al, 'X'`
- `int 0x10`

=> displays X.