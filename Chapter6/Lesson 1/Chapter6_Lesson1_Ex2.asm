; Chapter6_Lesson1_Ex2.asm
; Stack frame + locals: compute (a + b) * c using locals on the stack.
; We intentionally store intermediates in memory to illustrate stack-frame layout.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex2.asm -o ex2.o
;   ld ex2.o -o ex2
; Run:
;   ./ex2 ; echo $?   (exit status is low 8 bits of result)

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; uint64_t compute(uint64_t a, uint64_t b, uint64_t c)
; SysV args: RDI=a, RSI=b, RDX=c
; Return: RAX
compute:
    push rbp
    mov rbp, rsp
    sub rsp, 32              ; reserve 32 bytes for locals, keep alignment simple

    ; locals:
    ; [rbp-8]  = a
    ; [rbp-16] = b
    ; [rbp-24] = c
    ; [rbp-32] = tmp = a+b
    mov [rbp-8],  rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx

    mov rax, [rbp-8]
    add rax, [rbp-16]
    mov [rbp-32], rax

    mov rax, [rbp-32]
    imul rax, [rbp-24]       ; rax = (a+b)*c

    leave                    ; mov rsp,rbp ; pop rbp
    ret

_start:
    mov rdi, 5               ; a
    mov rsi, 9               ; b
    mov rdx, 7               ; c
    call compute

    ; exit code is mod 256; just for a quick "observable" outcome
    mov edi, eax
    mov eax, 60
    syscall
