; Chapter 5 - Lesson 8, Example 7
; Timing macros (header-like include) for microbench experiments.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

%macro TSC_SERIALIZE 0
    push rbx
    xor eax, eax
    cpuid
    pop rbx
%endmacro

%macro TSC_START 1
    TSC_SERIALIZE
    rdtsc
    shl rdx, 32
    or  rax, rdx
    mov %1, rax
%endmacro

%macro TSC_STOP 1
    rdtscp
    shl rdx, 32
    or  rax, rdx
    mov %1, rax
    TSC_SERIALIZE
%endmacro
