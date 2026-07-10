; ==============================================================================
;  Project: Boutaba-Kernel-Jitter-Clock-Verifier v3.0 (Hardened)
;  Developer: Boutaba Motezeballah — Systems Architect & Reverse Engineer
;  Architecture: x86_64 ASM (Linux Microarchitectural Auditing Platform)
;  Description: Safe Cycle-Level Timing Jitter Audit for Integrity Verification.
; ==============================================================================

section .text
    global _start

_start:
    push rbp
    mov rbp, rsp

    ; --------------------------------------------------------------------------
    ; 1. First Time-Stamp Capture (T1 Execution Frame)
    ; --------------------------------------------------------------------------
    xor rax, rax        ; Clear RAX to request CPUID leaf 0
    cpuid               ; Serialize instruction pipeline to prevent out-of-order execution
    rdtsc               ; Read hardware Time-Stamp Counter into EDX:EAX registers
    shl rdx, 32         ; Shift high 32-bits of counter to upper half of RDX
    or rax, rdx         ; Combine EDX and EAX into a single 64-bit value in RAX
    mov r8, rax         ; Store T1 baseline time-stamp inside R8 register

    ; --------------------------------------------------------------------------
    ; 2. Lightweight Target Execution Path (Deterministic Environment)
    ; --------------------------------------------------------------------------
    xor rbx, rbx        ; Clear RBX to guarantee a safe, non-overflow mathematical baseline
    mov rcx, 100        ; Initialize lightweight loop constraint counter
.audit_loop:
    add rbx, rcx        ; Trivial mathematical execution step
    dec rcx
    jnz .audit_loop     ; Recurse loop until counter reaches zero

    ; --------------------------------------------------------------------------
    ; 3. Second Time-Stamp Capture (T2 Execution Frame using Hardened RDTSCP)
    ; --------------------------------------------------------------------------
    rdtscp              ; Hardened read: serializes pipeline and extracts counter to EDX:EAX
    shl rdx, 32         ; Shift high 32-bits of counter
    or rax, rdx         ; Combine EDX and EAX into a single 64-bit value in RAX
    
    ; أمر RDTSCP يقوم بتغيير مسجل RCX تلقائياً، لكن حلقة الفحص انتهت فلا ضرر عتادي هنا

    ; --------------------------------------------------------------------------
    ; 4. Mathematical Delta Evaluation & Divergence Threshold Test
    ; --------------------------------------------------------------------------
    sub rax, r8         ; Compute Execution Delta: RAX (T2) - R8 (T1)
    
    ; Define the allowed execution threshold cycle index (e.g., 500 CPU cycles maximum)
    cmp rax, 500        ; Compare execution delta cycle runtime directly
    jg .anomaly_detected ; If execution delta is greater than 500 cycles, trigger defense

    ; --------------------------------------------------------------------------
    ; 5. Secure Integrity Verified Path (CLEAN EXIT)
    ; --------------------------------------------------------------------------
    mov rax, 60         ; syscall: sys_exit
    xor rdi, rdi        ; exit code = 0 (Operational flow verified securely)
    syscall

.anomaly_detected:
    ; --------------------------------------------------------------------------
    ; 6. Proactive Subversion Mitigation Path (ISOLATION EXIT)
    ; --------------------------------------------------------------------------
    mov rax, 60         ; syscall: sys_exit
    mov rdi, 120        ; exit code = 120 (Timing manipulation signature matched)
    syscall
