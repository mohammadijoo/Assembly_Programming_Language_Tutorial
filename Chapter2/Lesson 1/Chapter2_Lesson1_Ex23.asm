; Layout (offsets in bytes) for ctx struct:
;  0x00 rax
;  0x08 rbx
;  0x10 rcx
;  0x18 rdx
;  0x20 rsi
;  0x28 rdi
;  0x30 rbp
;  0x38 r8
;  0x40 r9
;  0x48 r10
;  0x50 r11
;  0x58 r12
;  0x60 r13
;  0x68 r14
;  0x70 r15
;  0x78 rflags
;  0x80 rip

%define CTX_RAX    0x00
%define CTX_RBX    0x08
%define CTX_RCX    0x10
%define CTX_RDX    0x18
%define CTX_RSI    0x20
%define CTX_RDI    0x28
%define CTX_RBP    0x30
%define CTX_R8     0x38
%define CTX_R9     0x40
%define CTX_R10    0x48
%define CTX_R11    0x50
%define CTX_R12    0x58
%define CTX_R13    0x60
%define CTX_R14    0x68
%define CTX_R15    0x70
%define CTX_RFLAGS 0x78
%define CTX_RIP    0x80

global save_ctx
save_ctx:
  ; RDI = &ctx
  mov [rdi + CTX_RAX], rax
  mov [rdi + CTX_RBX], rbx
  mov [rdi + CTX_RCX], rcx
  mov [rdi + CTX_RDX], rdx
  mov [rdi + CTX_RSI], rsi
  mov [rdi + CTX_RDI], rdi        ; store original RDI too (self-pointer)
  mov [rdi + CTX_RBP], rbp
  mov [rdi + CTX_R8],  r8
  mov [rdi + CTX_R9],  r9
  mov [rdi + CTX_R10], r10
  mov [rdi + CTX_R11], r11
  mov [rdi + CTX_R12], r12
  mov [rdi + CTX_R13], r13
  mov [rdi + CTX_R14], r14
  mov [rdi + CTX_R15], r15

  ; Save RFLAGS
  pushfq
  pop qword [rdi + CTX_RFLAGS]

  ; Save RIP using RIP-relative LEA (address of label .after)
  lea rax, [rel .after]
  mov [rdi + CTX_RIP], rax

.after:
  xor eax, eax                     ; return 0 (setjmp-like)
  ret

global load_ctx
load_ctx:
  ; RDI = &ctx
  ; Restore GPRs (except RSP) and RFLAGS.
  ; WARNING: restoring RDI early would lose ctx pointer, so do it last.

  mov rax, [rdi + CTX_RAX]
  mov rbx, [rdi + CTX_RBX]
  mov rcx, [rdi + CTX_RCX]
  mov rdx, [rdi + CTX_RDX]
  mov rsi, [rdi + CTX_RSI]
  mov rbp, [rdi + CTX_RBP]
  mov r8,  [rdi + CTX_R8]
  mov r9,  [rdi + CTX_R9]
  mov r10, [rdi + CTX_R10]
  mov r11, [rdi + CTX_R11]
  mov r12, [rdi + CTX_R12]
  mov r13, [rdi + CTX_R13]
  mov r14, [rdi + CTX_R14]
  mov r15, [rdi + CTX_R15]

  ; Restore RFLAGS
  push qword [rdi + CTX_RFLAGS]
  popfq

  ; Jump to saved RIP (indirect control transfer)
  mov rax, [rdi + CTX_RIP]
  mov rdi, [rdi + CTX_RDI]         ; restore RDI last
  jmp rax
