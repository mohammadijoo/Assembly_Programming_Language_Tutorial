; Chapter6_Lesson1_Ex12.asm
; Exercise Solution (Very Hard): Tail-call style procedure via a loop (manual TCO mindset).
; Implement gcd(a, b) using Euclid:
;   while (b != 0) { (a, b) = (b, a % b); }
; Return a.
;
; Demonstrates:
;   - procedure as reusable unit
;   - "tail call" elimination by turning self-call into a jump/loop
;   - careful DIV usage on x86-64 (RDX:RAX / r/m64)
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex12.asm -o ex12.o
;   ld ex12.o -o ex12
; Run:
;   ./ex12 ; echo $?  (gcd(252,105)=21 -> exit 21)

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; uint64_t gcd(uint64_t a, uint64_t b)
; args: RDI=a, RSI=b ; return RAX
gcd:
    ; We'll implement as a loop. No frame pointer needed (leaf-ish), but clear & safe.
.loop:
    test rsi, rsi
    jz .done

    ; Compute a % b:
    ; dividend in RDX:RAX. For unsigned, clear RDX and set RAX=a.
    mov rax, rdi
    xor rdx, rdx
    div rsi                    ; quotient in RAX, remainder in RDX

    ; (a, b) = (b, rdx)
    mov rdi, rsi
    mov rsi, rdx
    jmp .loop

.done:
    mov rax, rdi
    ret

_start:
    mov rdi, 252
    mov rsi, 105
    call gcd                   ; rax = 21
    mov edi, eax
    mov eax, 60
    syscall
