; file: abi_defs.inc  (NASM-style include)
%ifndef ABI_DEFS_INC
%define ABI_DEFS_INC

; Stack alignment requirement at call boundaries (SysV AMD64): 16 bytes
%define STACK_ALIGN 16

; Example: bit masks for RFLAGS (subset)
%define RFLAGS_CF (1 << 0)
%define RFLAGS_ZF (1 << 6)
%define RFLAGS_SF (1 << 7)
%define RFLAGS_OF (1 << 11)

; Macro: save a caller-defined set of registers (example)
%macro SAVE_REGS 0
  push rbx
  push rbp
  push r12
  push r13
  push r14
  push r15
%endmacro

%macro RESTORE_REGS 0
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  pop rbx
%endmacro

%endif
