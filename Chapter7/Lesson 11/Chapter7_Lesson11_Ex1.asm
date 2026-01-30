; Chapter 7 - Lesson 11 - Example 1
; Topic: Heap Use-After-Free (UAF) as a logic corruption (address reuse demo)
; Platform: Linux x86-64 (SysV ABI), NASM syntax
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex1.asm -o ex1.o
;   gcc -no-pie ex1.o -o ex1
;
; Run:
;   ./ex1
;
; Note:
;   This program only performs the UAF write if the allocator reuses the same
;   address for a same-size allocation, to avoid corrupting allocator metadata.

default rel
global main

extern malloc
extern free

section .data
msg0           db "== UAF demo (heap address reuse) ==", 10
msg0_len       equ $-msg0

msgA           db "A (freed) pointer: "
msgA_len       equ $-msgA

msgB           db "B (live)  pointer: "
msgB_len       equ $-msgB

msgReuse       db "Allocator reused the address; writing through the freed alias corrupts the live object.", 10
msgReuse_len   equ $-msgReuse

msgNoReuse     db "Allocator did not reuse the address this run; we will NOT write to the freed block (to avoid heap metadata corruption).", 10
msgNoReuse_len equ $-msgNoReuse

msgDump        db "First 16 bytes of B:", 10
msgDump_len    equ $-msgDump

nl             db 10
hexdigits      db "0123456789abcdef"

section .bss
hexbuf         resb 18
bytebuf        resb 3

section .text

; write(1, rsi, rdx)
write1:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_nl:
    lea rsi, [rel nl]
    mov edx, 1
    jmp write1

; rdi = uint64 value
print_hex64:
    push rbx
    mov rax, rdi
    lea rsi, [rel hexbuf]
    mov byte [rsi], '0'
    mov byte [rsi+1], 'x'
    lea rbx, [rsi+2]
    mov ecx, 16
.hex_loop:
    mov rdx, rax
    shr rdx, 60
    mov dl, dl
    cmp dl, 9
    jbe .dig
    add dl, 'a' - 10
    jmp .st
.dig:
    add dl, '0'
.st:
    mov [rbx], dl
    inc rbx
    shl rax, 4
    dec ecx
    jnz .hex_loop
    lea rsi, [rel hexbuf]
    mov edx, 18
    call write1
    pop rbx
    ret

; rdi = ptr, esi = len (bytes)
dump_bytes_hex:
    push rbx
    push r12
    mov r12, rdi
    mov ebx, esi
    xor ecx, ecx
.loop:
    cmp ecx, ebx
    jae .done

    movzx eax, byte [r12 + rcx]
    mov edx, eax
    shr edx, 4
    and eax, 0x0F

    lea r8, [rel hexdigits]
    mov dl, byte [r8 + rdx]      ; high nibble
    mov byte [bytebuf], dl
    mov dl, byte [r8 + rax]      ; low nibble
    mov byte [bytebuf+1], dl
    mov byte [bytebuf+2], ' '

    lea rsi, [rel bytebuf]
    mov edx, 3
    call write1

    inc ecx
    jmp .loop

.done:
    call print_nl
    pop r12
    pop rbx
    ret

main:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    ; A = malloc(32)
    mov edi, 32
    call malloc
    test rax, rax
    je .exit_fail
    mov rbx, rax

    ; fill A with 'A'
    mov rdi, rbx
    mov ecx, 32
    mov al, 'A'
    rep stosb

    ; free(A)
    mov rdi, rbx
    call free

    ; B = malloc(32)
    mov edi, 32
    call malloc
    test rax, rax
    je .exit_fail
    mov r12, rax

    ; fill B with 'B'
    mov rdi, r12
    mov ecx, 32
    mov al, 'B'
    rep stosb

    ; print A ptr
    lea rsi, [rel msgA]
    mov edx, msgA_len
    call write1
    mov rdi, rbx
    call print_hex64
    call print_nl

    ; print B ptr
    lea rsi, [rel msgB]
    mov edx, msgB_len
    call write1
    mov rdi, r12
    call print_hex64
    call print_nl

    cmp rbx, r12
    jne .no_reuse

    lea rsi, [rel msgReuse]
    mov edx, msgReuse_len
    call write1

    ; UAF write is now writing into B (same address)
    mov qword [rbx], 0x5858585858585858  ; 'X' * 8

    lea rsi, [rel msgDump]
    mov edx, msgDump_len
    call write1

    mov rdi, r12
    mov esi, 16
    call dump_bytes_hex
    jmp .cleanup

.no_reuse:
    lea rsi, [rel msgNoReuse]
    mov edx, msgNoReuse_len
    call write1

.cleanup:
    mov rdi, r12
    call free
    xor eax, eax
    ret

.exit_fail:
    mov eax, 60
    mov edi, 1
    syscall
