; Chapter 6 - Lesson 7 - Exercise 3 (Solution)
; Title: Calling a "Microsoft x64 ABI" callee from a SysV caller (within pure assembly)
;
; Why this matters:
;   - Cross-language / cross-toolchain modules may use different ABIs.
;   - If you must bridge, you need correct register mapping + stack rules.
;
; This file can be assembled and linked on Linux. It demonstrates the mechanism
; without requiring Windows APIs.
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    ; We'll compute: ms_add4_u64(10,20,30,40) = 100
    mov edi, 10
    mov esi, 20
    mov edx, 30
    mov ecx, 40
    call call_ms_add4_from_sysv

    ; Exit with low byte (100)
    mov edi, eax
    mov eax, 60
    syscall

; -------------------------------------------------------------
; SysV function:
; uint64_t call_ms_add4_from_sysv(uint64 a, uint64 b, uint64 c, uint64 d)
; SysV args: RDI, RSI, RDX, RCX
; Calls ms_add4_u64 which expects MS-ABI args: RCX, RDX, R8, R9
call_ms_add4_from_sysv:
    push rbp
    mov rbp, rsp

    ; Map SysV args -> MS args
    mov r8,  rdx
    mov r9,  rcx
    mov rcx, rdi
    mov rdx, rsi

    ; MS x64 requires 32-byte shadow space for every call.
    ; Also keep 16-byte alignment at the call-site.
    ;
    ; At SysV function entry: rsp%16 == 8
    ; push rbp => rsp%16 == 0
    ; We want rsp%16 == 0 at call-site, and reserve 32 bytes:
    sub rsp, 32

    call ms_add4_u64

    add rsp, 32
    pop rbp
    ret

; -------------------------------------------------------------
; "Microsoft x64 ABI style" callee:
; uint64_t ms_add4_u64(uint64 a, uint64 b, uint64 c, uint64 d)
; Args: RCX, RDX, R8, R9
ms_add4_u64:
    ; Leaf: no need to allocate stack, but it *may* use shadow space if needed.
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    ret
