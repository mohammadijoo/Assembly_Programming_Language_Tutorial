; Chapter7_Lesson8_Ex10.asm
; Exercise Solution: Count mappings with execute permission by parsing /proc/self/maps.
; Hard: simple line parser that checks the 'x' in the 4-char perms field.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

section .data
path: db "/proc/self/maps", 0
msg: db "Executable mappings (perms have 'x'): "
len_msg: equ $-msg
nl: db 10

section .bss
buf:   resb 65536
numbuf: resb 32

section .text
_start:
    and rsp, -16

    ; fd = open(path, O_RDONLY, 0)
    syscall3 SYS_open, path, O_RDONLY, 0
    test rax, rax
    js .fail
    mov r12, rax

    ; Read up to 64KiB (maps is typically smaller; for huge processes increase this)
    xor r13, r13             ; total bytes read
.read_more:
    lea rsi, [rel buf + r13]
    mov rdx, 65536
    sub rdx, r13
    jle .parse
    syscall3 SYS_read, r12, rsi, rdx
    test rax, rax
    js .parse
    jz .parse
    add r13, rax
    jmp .read_more

.parse:
    syscall1 SYS_close, r12

    ; Parse line by line in [buf, buf+r13)
    xor r14, r14             ; i = 0
    xor r15, r15             ; count = 0

.next_line:
    cmp r14, r13
    jae .done

    ; line_start = buf + i
    lea rbx, [rel buf]
    add rbx, r14

    ; Find '\n' to get line_end
    mov rcx, r14
.find_nl:
    cmp rcx, r13
    jae .line_end_at_eof
    mov al, [rel buf + rcx]
    cmp al, 10
    je .have_line_end
    inc rcx
    jmp .find_nl

.line_end_at_eof:
    mov rcx, r13

.have_line_end:
    ; Now parse the line: find first space ' '
    mov rdx, r14             ; cursor = i
.find_sp:
    cmp rdx, rcx
    jae .advance_line
    mov al, [rel buf + rdx]
    cmp al, ' '
    je .check_perms
    inc rdx
    jmp .find_sp

.check_perms:
    ; perms_start = (space + 1)
    lea rsi, [rel buf + rdx + 1]
    ; perms[2] == 'x' ?
    mov al, [rsi + 2]
    cmp al, 'x'
    jne .advance_line
    inc r15

.advance_line:
    ; i = line_end + 1
    mov r14, rcx
    cmp r14, r13
    jae .done
    inc r14
    jmp .next_line

.done:
    syscall3 SYS_write, 1, msg, len_msg
    mov rax, r15
    call u64_to_dec_nolf
    syscall3 SYS_write, 1, rsi, rdx
    syscall3 SYS_write, 1, nl, 1
    syscall1 SYS_exit, 0

.fail:
    syscall1 SYS_exit, 1

; Convert unsigned rax to decimal ASCII (no newline)
; Output: rsi=ptr, rdx=len
u64_to_dec_nolf:
    push rbx
    lea rbx, [rel numbuf + 31]
    mov byte [rbx], 0
    dec rbx

    cmp rax, 0
    jne .loop

    mov byte [rbx], '0'
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret

.loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rbx], dl
    dec rbx
    test rax, rax
    jne .loop

    inc rbx
    mov rsi, rbx
    lea rdx, [rel numbuf + 32]
    sub rdx, rsi
    pop rbx
    ret
