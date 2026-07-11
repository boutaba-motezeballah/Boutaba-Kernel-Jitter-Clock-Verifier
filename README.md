# RDTSC Anti-Debugging (PoC)

## Overview
This repository contains a low-level anti-debugging Proof-of-Concept (PoC) implemented in **pure x86_64 Assembly** for Linux. It utilizes the Time-Stamp Counter (`RDTSC`) to detect timing anomalies introduced by software debuggers (like GDB), interactive tracers, or dynamic analysis sandboxes.

## How it Works
The utility measures the exact number of CPU clock cycles elapsed between two execution points. Under a debugger or an emulated environment, step-by-step execution or execution hooks drastically increase latency.

### Core Execution Flow:
1. **Serialization (`CPUID`):** Flushes the processor pipeline to guarantee timing precision and clear out speculative execution artifacts.
2. **First Timestamp (`RDTSC`):** Captures the initial CPU cycle count.
3. **Execution Barrier (`LFENCE`):** Prevents instruction reordering around the measurement block.
4. **Second Timestamp (`RDTSC`):** Captures the trailing cycle count.
5. **Delta Assessment:** Computes the difference. If the execution cycle delta exceeds the predefined threshold (e.g., ~500 cycles), an anomaly is identified, and the program exits with code `120`. Otherwise, it exits safely (`0`).

## Compilation and Usage
To build the project natively on an x86_64 Linux system:

```bash
# Assemble the source file
nasm -f elf64 clock_verifier.asm -o clock_verifier.o

# Link the object file into a static binary
ld clock_verifier.o -o rdtsc_verifier

# Run the test binary
./rdtsc_verifier
```

## Practical Application
In production malware analysis defenses, this assembly routine is typically implemented as an inline macro inside a larger application rather than running as a standalone tool.
