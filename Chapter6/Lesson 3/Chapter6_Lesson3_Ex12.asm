; Chapter6_Lesson3_Ex12.asm
; Programming Exercise 3 (Very Hard): call a function pointer with 8 integer args
; supplied in an array, using SysV AMD64 rules (regs + stack spillover + alignment).
;
; We implement:
;   int64 call8_sysv(int64 (*fn)(...), const int64 *args8)
; where args8[0..7] are a1..a8.
; SysV: fn=RDI, args8=RSI
;
; Critical detail: before CALL, RSP must be 16-byte aligned.
; call8_sysv is itself entered with RSP = 8 (mod 16), so we insert 8 bytes
; of padding before pushing the two stack args.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
; Run:
;   ./ex12 ; exit code = 36

global _start

section .data
args8 dq 1,2,3,4,5,6,7,8

section .text

sum8_target:
    push    rbp
    mov     rbp, rsp

    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9
    add     rax, [rbp + 16]    ; a7
    add     rax, [rbp + 24]    ; a8

    pop     rbp
    ret

call8_sysv:
    ; Save fn pointer and args pointer
    mov     r11, rdi           ; fn
    mov     r10, rsi           ; args8

    ; Load first 6 args into register argument slots
    mov     rdi, [r10 + 0]
    mov     rsi, [r10 + 8]
    mov     rdx, [r10 + 16]
    mov     rcx, [r10 + 24]
    mov     r8,  [r10 + 32]
    mov     r9,  [r10 + 40]

    ; Stack args a7, a8 must be adjacent above return address.
    ; Align RSP to 16 before the CALL by adding 8 bytes of padding first.
    sub     rsp, 8             ; padding (keeps stack-args adjacency)
    push    qword [r10 + 56]   ; a8 (right-to-left)
    push    qword [r10 + 48]   ; a7
    call    r11
    add     rsp, 24            ; pop a7,a8 + remove padding
    ret

_start:
    lea     rsi, [rel args8]
    lea     rdi, [rel sum8_target]
    call    call8_sysv

    mov     edi, eax
    mov     eax, 60
    syscall
