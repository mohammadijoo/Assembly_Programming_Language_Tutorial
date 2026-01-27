; Chapter6_Lesson9_Ex7.asm
; Programming Exercise (Solution):
; Return a "slice" (ptr,len) as a 16-byte struct via RAX/RDX.
;
; C model:
;   struct slice { void* ptr; uint64_t len; };
;   struct slice clip_slice(void* p, uint64_t len, uint64_t max);
;
; Semantics:
;   return {p, min(len, max)}
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o

global _start

section .text

clip_slice:
    ; p in RDI, len in RSI, max in RDX
    mov     rax, rdi            ; ptr return
    mov     rcx, rsi
    cmp     rcx, rdx
    cmova   rcx, rdx            ; rcx = (len > max) ? max : len
    mov     rdx, rcx            ; len return in RDX
    ret

_start:
    ; pretend pointer value is 0x1000 (we won't dereference it)
    mov     rdi, 0x1000
    mov     rsi, 99
    mov     rdx, 64
    call    clip_slice

    cmp     rax, 0x1000
    jne     .fail
    cmp     rdx, 64
    jne     .fail

    mov     rdi, 0x2000
    mov     rsi, 5
    mov     rdx, 64
    call    clip_slice
    cmp     rax, 0x2000
    jne     .fail
    cmp     rdx, 5
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
