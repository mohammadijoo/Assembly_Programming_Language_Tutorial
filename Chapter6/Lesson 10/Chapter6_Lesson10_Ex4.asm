; Chapter 6 - Lesson 10 (Ex4): SysV AMD64 - A minimal va_arg-like routine for int64
; This is a *teaching* implementation following the SysV AMD64 ABI va_list layout.
; It supports fetching a 64-bit integer argument (one GP register slot or one stack slot).
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex4.asm -o ex4.o
;   gcc -no-pie ex4.o -o ex4_test   (link with a driver, e.g., Ex5)
;
; ABI reference for va_list fields and offsets (gp_offset/fp_offset/overflow_arg_area/reg_save_area).

default rel
bits 64

global sysv_va_arg_i64

section .text
; int64_t sysv_va_arg_i64(struct_va_list *ap)
; RDI = pointer to struct { uint32 gp_offset; uint32 fp_offset; void* overflow; void* reg_save; }
; Returns: RAX = next int64
sysv_va_arg_i64:
    ; Load gp_offset (uint32)
    mov eax, dword [rdi + 0]
    cmp eax, 40                 ; 48-8: last available GP slot start
    ja  .from_overflow

    ; From reg_save_area + gp_offset
    mov rdx, [rdi + 16]         ; reg_save_area
    mov rax, [rdx + rax]        ; fetch qword
    add dword [rdi + 0], 8      ; gp_offset += 8
    ret

.from_overflow:
    mov rdx, [rdi + 8]          ; overflow_arg_area
    mov rax, [rdx]              ; fetch qword
    add rdx, 8
    mov [rdi + 8], rdx          ; overflow_arg_area += 8
    ret
