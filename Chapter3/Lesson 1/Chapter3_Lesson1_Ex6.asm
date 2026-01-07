; Chapter3_Lesson1_Ex6.asm
; Lesson goal: Stack storage as memory: locals, alignment, and addresses.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex6.asm -o ex6.o
;   ld ex6.o -o ex6
; Run:
;   ./ex6

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
intro db "Stack local storage demo:", 10, 0
m_rsp db "  RSP (after allocation) = 0x", 0
m_l0  db "  &local0 (qword) = 0x", 0
m_l1  db "  &local1 (qword) = 0x", 0
m_v0  db "  local0 value = 0x", 0
m_v1  db "  local1 value = 0x", 0

section .text
global _start
_start:
    lea rdi, [intro]
    call write_z

    ; Allocate 32 bytes of local space.
    ; SysV ABI requires 16-byte alignment before calls; we keep it aligned here.
    sub rsp, 32

    ; local0 at [rsp+0], local1 at [rsp+8]
    mov qword [rsp + 0], 0x1111222233334444
    mov qword [rsp + 8], 0xaaaaaaaa55555555

    mov rax, rsp
    lea rdi, [m_rsp]
    call write_str_and_hex64

    lea rax, [rsp + 0]
    lea rdi, [m_l0]
    call write_str_and_hex64

    lea rax, [rsp + 8]
    lea rdi, [m_l1]
    call write_str_and_hex64

    mov rax, [rsp + 0]
    lea rdi, [m_v0]
    call write_str_and_hex64

    mov rax, [rsp + 8]
    lea rdi, [m_v1]
    call write_str_and_hex64

    add rsp, 32
    sys_exit 0
