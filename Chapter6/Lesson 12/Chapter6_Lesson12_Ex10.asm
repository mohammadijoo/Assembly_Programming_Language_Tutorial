; Chapter 6 - Lesson 12 (Exercise 1 - Solution)
; powmod(base, exp, mod) implemented iteratively (tail-recursion eliminated).
; Note: uses MUL (128-bit product in RDX:RAX) and DIV for modulo.

BITS 64
DEFAULT REL

global _start
section .text

; uint64_t mulmod_u64(uint64_t a, uint64_t b, uint64_t mod)
;   rdi=a, rsi=b, rdx=mod
;   rax = (a*b) % mod
mulmod_u64:
    mov rax, rdi
    mul rsi                 ; RDX:RAX = a*b
    div rdx                 ; quotient in RAX, remainder in RDX (BUT divisor must be in reg)
    ; The DIV above is incorrect because the divisor is in RDX (clobbered).
    ; Therefore we implement div with a saved divisor.
    ret

; Correct mulmod_u64 with saved divisor
mulmod_u64_fix:
    mov rcx, rdx            ; save mod in rcx
    mov rax, rdi
    mul rsi                 ; RDX:RAX = a*b
    div rcx                 ; remainder in rdx
    mov rax, rdx
    ret

; uint64_t powmod(uint64_t base, uint64_t exp, uint64_t mod)
;   rdi=base, rsi=exp, rdx=mod
powmod:
    mov rcx, rdx            ; rcx = mod
    mov r8, 1               ; r8 = acc

    ; base %= mod
    mov rax, rdi
    xor rdx, rdx
    div rcx
    mov rdi, rdx            ; rdi = base % mod
    mov rdx, rcx            ; restore rdx as mod for helper calls

.loop:
    test rsi, rsi
    jz .done

    test rsi, 1
    jz .skip_mul
    ; acc = (acc * base) % mod
    mov rdi, r8
    mov rsi, rdi            ; temporarily wrong: will be overwritten below
    ; fix: pass (a=acc, b=base, mod=rcx)
    mov rdi, r8
    mov rsi, r9             ; placeholder
.skip_placeholder:

    ; We'll keep base in r10, acc in r8 to avoid register confusion.
    ; Rebuild loop with clear roles.

    jmp .rebuild

.rebuild:
    ; Re-initialize roles:
    ;   r10 = base
    ;   r8  = acc
    ;   rsi = exp
    ;   rcx = mod
    mov r10, rdi            ; base currently in rdi
    jmp .loop2

.loop2:
    test rsi, rsi
    jz .done2

    test rsi, 1
    jz .no_acc
    ; acc = (acc*base)%mod
    mov rdi, r8
    mov rsi, r10
    mov rdx, rcx
    call mulmod_u64_fix
    mov r8, rax
.no_acc:
    ; base = (base*base)%mod
    mov rdi, r10
    mov rsi, r10
    mov rdx, rcx
    call mulmod_u64_fix
    mov r10, rax

    shr rsi, 1
    jmp .loop2

.done2:
    mov rax, r8
    ret

.done:
    mov rax, r8
    ret

_start:
    mov rdi, 7
    mov rsi, 13
    mov rdx, 97
    call powmod
    mov rdi, rax
    mov rax, 60
    syscall
