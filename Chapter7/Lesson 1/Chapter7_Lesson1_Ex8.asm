; Chapter 7 - Lesson 1
; Exercise Solution 2:
;   32-byte aligned stack allocation with metadata for safe deallocation.
;
; API:
;   rax = stack_alloc32(size=rdi)
;   stack_free32(ptr=rax)   ; uses metadata to restore previous RSP
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;   ./ex8

global _start

section .data
msg: db "Allocated 32B-aligned stack buffer at: 0x"
msg_l: equ $-msg
hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16+1

section .text

_start:
    mov rdi, 160                ; allocate 160 bytes
    call stack_alloc32          ; rax = aligned pointer

    ; print pointer
    mov rdi, msg
    mov rsi, msg_l
    call write_buf
    mov rax, rax
    call print_hex64

    ; write something into the buffer so it's not optimized away
    mov rcx, 160
    mov rbx, rax
.fill:
    mov byte [rbx + rcx - 1], 0xA5
    loop .fill

    ; free using metadata stored *just before* the aligned pointer
    call stack_free32

    xor edi, edi
    mov eax, 60
    syscall

; ------------------------------------------------------------
; stack_alloc32(rdi=size) -> rax=ptr (32B aligned)
;
; Layout (stack grows down):
;   [ ... raw reserved bytes ... ]
;   metadata (8 bytes): old_rsp
;   padding
;   aligned pointer returned (points AFTER metadata)
;
; We store old_rsp at [ptr - 8].
; ------------------------------------------------------------
stack_alloc32:
    mov rdx, rsp                ; old_rsp
    mov rax, rdi
    add rax, 8                  ; include metadata slot
    add rax, 31                 ; worst-case padding to reach 32B alignment
    sub rsp, rax

    ; compute aligned ptr >= rsp, 32B aligned, leaving room for metadata
    lea rax, [rsp + 8 + 31]
    and rax, -32                ; 32-byte alignment
    mov [rax - 8], rdx          ; store old_rsp metadata
    ret

; stack_free32(rax=ptr)
stack_free32:
    mov rsp, [rax - 8]
    ret

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

print_hex64:
    lea rdi, [rel hexbuf]
    mov rcx, 16
    lea r8,  [rel hex_digits]
.loop:
    mov r9, rax
    shr r9, 60
    mov r9b, [r8 + r9]
    mov [rdi], r9b
    inc rdi
    shl rax, 4
    dec rcx
    jnz .loop
    mov byte [rdi], 10
    lea rdi, [rel hexbuf]
    mov rsi, 17
    jmp write_buf
