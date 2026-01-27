bits 64
default rel
global _start

%define ARR_LEN 16

section .data
arr: dq 3, 7, 11, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71

section .text
_start:
    ; Exercise solution: binary search
    ;   - binsearch_rec: explicit recursion
    ;   - binsearch_tco: tail-recursive form turned into a loop

    lea rdi, [rel arr]        ; base
    xor esi, esi              ; lo = 0
    mov edx, ARR_LEN          ; hi = len (exclusive)
    mov ecx, 47               ; key
    call binsearch_rec
    mov rbx, rax

    lea rdi, [rel arr]
    xor esi, esi
    mov edx, ARR_LEN
    mov ecx, 47
    call binsearch_tco

    ; Both must match and equal 10 (0-based)
    cmp rax, rbx
    jne .bad
    cmp rax, 10
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; int64_t binsearch_rec(int64_t* base, uint64_t lo, uint64_t hi, int64_t key)
; Args:
;   RDI=base, RSI=lo, RDX=hi(exclusive), RCX=key
; Returns:
;   RAX=index, or -1 if not found
binsearch_rec:
    cmp rsi, rdx
    jae .notfound

    mov r8, rsi
    add r8, rdx
    shr r8, 1                 ; mid = (lo+hi)/2

    mov r9, [rdi + r8*8]      ; arr[mid]
    cmp rcx, r9
    je .found
    jb .left                  ; key < arr[mid]

.right:
    lea rsi, [r8 + 1]         ; lo = mid+1
    call binsearch_rec        ; tail position, but we keep it as CALL to show recursion
    ret

.left:
    mov rdx, r8               ; hi = mid
    call binsearch_rec
    ret

.found:
    mov rax, r8
    ret

.notfound:
    mov rax, -1
    ret

; int64_t binsearch_tco(base, lo, hi, key) - loop form (tail recursion eliminated)
binsearch_tco:
.loop:
    cmp rsi, rdx
    jae .notfound2

    mov r8, rsi
    add r8, rdx
    shr r8, 1

    mov r9, [rdi + r8*8]
    cmp rcx, r9
    je .found2
    jb .left2

.right2:
    lea rsi, [r8 + 1]
    jmp .loop

.left2:
    mov rdx, r8
    jmp .loop

.found2:
    mov rax, r8
    ret

.notfound2:
    mov rax, -1
    ret
