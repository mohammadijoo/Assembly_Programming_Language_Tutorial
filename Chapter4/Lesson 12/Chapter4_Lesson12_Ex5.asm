; Chapter 4 - Lesson 12 (Ex5)
; Implicit operands: string ops (MOVS*, STOS*, LODS*, SCAS*, CMPS*) use RSI/RDI/RCX and DF.
; Pitfall: DF (Direction Flag) changes pointer direction. If DF=1, REP MOVSB copies backwards.
; Defensive rule: clear DF (CLD) in any routine that uses string ops unless your contract says otherwise.

bits 64
default rel
global _start

section .data
src:    db "abcdefghij", 0
dst:    times 11 db 0

section .text
_start:
    ; Demonstrate safe forward copy with REP MOVSB
    lea     rsi, [src]
    lea     rdi, [dst]
    mov     ecx, 11

    cld                         ; DF=0: forward
    rep movsb                   ; implicit: uses RSI/RDI/RCX, updates RSI/RDI, decrements RCX

    ; Pitfall demonstration (disabled): setting DF but still expecting forward copy
%if 0
    lea     rsi, [src]
    lea     rdi, [dst]
    mov     ecx, 11
    std                         ; DF=1
    rep movsb                   ; copies backwards; also RSI/RDI end at start-1
%endif

    ; Exit(0)
    mov     eax, 60
    xor     edi, edi
    syscall
