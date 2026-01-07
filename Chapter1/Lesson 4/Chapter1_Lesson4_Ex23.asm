; file: platform_constants.inc (conceptual)
; Purpose: unify a few constants behind names.

; --- Linux x86-64 syscall numbers (partial, illustrative) ---
%define SYS_write_x86_64 1
%define SYS_exit_x86_64  60

; --- Linux AArch64 syscall numbers (partial, illustrative) ---
%define SYS_write_aarch64 64
%define SYS_exit_aarch64  93

; --- Linux RISC-V syscall numbers (partial, illustrative) ---
%define SYS_write_riscv 64
%define SYS_exit_riscv  93

; NOTE: exact values and mechanisms are OS/ABI-specific and will be treated formally later.
