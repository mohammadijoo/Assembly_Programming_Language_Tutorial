; Chapter7_Lesson10_Ex8.asm
; Topic: Heap block with header tags (magic/len/state) + checked access (mmap-backed)
; Build:
;   nasm -felf64 Chapter7_Lesson10_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o

bits 64
default rel

%define SYS_write  1
%define SYS_exit   60
%define SYS_mmap   9
%define SYS_munmap 11

%define PROT_READ    1
%define PROT_WRITE   2
%define MAP_PRIVATE  2
%define MAP_ANON     32

; 64-bit tag value. We compare memory against a register holding this value
; to avoid "cmp mem, imm64" limitations.
%define MAGIC_LIVE  0x4D454D5F53414645    ; "MEM_SAFE" as ASCII-ish tag

section .data
msg_ok      db "Allocated, checked store, and freed safely.", 10
msg_ok_len  equ $-msg_ok
msg_bad     db "Rejected invalid access (tag/state/bounds).", 10
msg_bad_len equ $-msg_bad

section .text
global _start

write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

exit_:
    mov eax, SYS_exit
    syscall

; alloc_block(len=rdi) -> rax=data_ptr, rdx=base_ptr, rcx=map_size
alloc_block:
    mov r11, rdi              ; requested len
    mov rcx, 4096             ; one page demo (keeps math simple)

    ; mmap(addr=0, size=rcx, prot=RW, flags=PRIVATE|ANON, fd=-1, off=0)
    xor edi, edi
    mov rsi, rcx
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_PRIVATE | MAP_ANON
    mov r8, -1
    xor r9d, r9d
    mov eax, SYS_mmap
    syscall
    cmp rax, -4095
    jae .fail

    mov rdx, rax              ; base
    mov rbx, MAGIC_LIVE
    mov [rdx + 0], rbx
    mov [rdx + 8], r11         ; len
    mov qword [rdx + 16], 1    ; state=LIVE
    lea rax, [rdx + 24]        ; data ptr
    ret
.fail:
    xor eax, eax
    ret

; checked_store_byte(data=rdi, off=rsi, val=dl) -> eax=0 ok, 1 fail
checked_store_byte:
    lea rbx, [rdi - 24]       ; base
    mov rax, MAGIC_LIVE
    cmp [rbx + 0], rax
    jne .fail
    cmp qword [rbx + 16], 1
    jne .fail
    mov rcx, [rbx + 8]        ; len
    cmp rsi, rcx
    jae .fail
    mov [rdi + rsi], dl
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

; free_block(data=rdi) -> eax=0 ok, 1 fail
free_block:
    lea rbx, [rdi - 24]       ; base
    mov rax, MAGIC_LIVE
    cmp [rbx + 0], rax
    jne .ffail
    cmp qword [rbx + 16], 1
    jne .ffail

    ; poison first 64 bytes of data for demo
    lea rdi, [rbx + 24]
    mov al, 0xCC
    mov rcx, 64
    rep stosb

    mov qword [rbx + 16], 0
    ; munmap(base, 4096)
    mov rdi, rbx
    mov rsi, 4096
    mov eax, SYS_munmap
    syscall
    xor eax, eax
    ret
.ffail:
    mov eax, 1
    ret

_start:
    ; Allocate 128 bytes
    mov rdi, 128
    call alloc_block
    test rax, rax
    jz .bad

    mov r12, rax              ; data ptr

    ; Checked store at offset 10
    mov rdi, r12
    mov rsi, 10
    mov dl, 0x7A
    call checked_store_byte
    test eax, eax
    jne .bad

    ; Free
    mov rdi, r12
    call free_block
    test eax, eax
    jne .bad

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call write_stdout
    xor edi, edi
    jmp exit_

.bad:
    lea rsi, [msg_bad]
    mov edx, msg_bad_len
    call write_stdout
    mov edi, 1
    jmp exit_
