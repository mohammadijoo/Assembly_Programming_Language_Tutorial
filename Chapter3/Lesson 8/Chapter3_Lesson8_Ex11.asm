BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Very hard exercise solution:
; Parse a hex string into an unsigned 128-bit integer (hi:lo) with overflow checking.

section .rodata
hdr  db "atoi_hex_u128 demo (hex -> 128-bit, hi:lo)",10,0
in1  db "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",0   ; max u128
in2  db "1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",0  ; overflow (33 digits)
lab  db "Input: ",0
ok1  db "  Parsed hi: ",0
ok2  db "  Parsed lo: ",0
bad  db "  Error: invalid hex or overflow",10,0

section .text
global _start

; -----------------------------------------------------------------------------
; hexchar_to_nibble
;   dl = input char
;   returns r8b = nibble (0..15), CF=0 success, CF=1 invalid
; -----------------------------------------------------------------------------
hexchar_to_nibble:
    cmp dl, '0'
    jb .bad
    cmp dl, '9'
    jbe .digit
    cmp dl, 'A'
    jb .lower_check
    cmp dl, 'F'
    jbe .upper
.lower_check:
    cmp dl, 'a'
    jb .bad
    cmp dl, 'f'
    jbe .lower
    jmp .bad

.digit:
    mov r8b, dl
    sub r8b, '0'
    clc
    ret

.upper:
    mov r8b, dl
    sub r8b, 'A'
    add r8b, 10
    clc
    ret

.lower:
    mov r8b, dl
    sub r8b, 'a'
    add r8b, 10
    clc
    ret

.bad:
    stc
    ret

; -----------------------------------------------------------------------------
; atoi_hex_u128
;   rsi = input string (optional 0x/0X)
;   outputs:
;     rdi = hi, rax = lo
;     CF  = 0 ok, CF = 1 error
; -----------------------------------------------------------------------------
atoi_hex_u128:
    xor rdi, rdi              ; hi
    xor rax, rax              ; lo
    xor ecx, ecx              ; digit count

    ; optional prefix
    cmp byte [rsi], '0'
    jne .loop
    mov dl, [rsi+1]
    cmp dl, 'x'
    je .skip2
    cmp dl, 'X'
    jne .loop
.skip2:
    add rsi, 2

.loop:
    mov dl, [rsi]
    cmp dl, 0
    je .done_check

    call hexchar_to_nibble
    jc .fail

    ; overflow check for 128-bit shift-left by 4:
    test rdi, 0xF000000000000000
    jnz .overflow

    ; (hi:lo) <<= 4
    mov r9, rax
    shr r9, 60
    shl rax, 4
    shl rdi, 4
    or  rdi, r9

    ; add nibble to lo
    movzx r10, r8b
    add rax, r10
    jc .carry
.no_carry:
    inc ecx
    inc rsi
    jmp .loop

.carry:
    inc rdi
    ; if hi overflows, that's beyond 128-bit range (impossible here after shift check)
    jz .overflow
    jmp .no_carry

.done_check:
    test ecx, ecx
    jz .fail
    clc
    ret

.overflow:
.fail:
    stc
    ret

; -----------------------------------------------------------------------------
; driver
; -----------------------------------------------------------------------------
_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    lea rsi, [in1]
    call demo_one
    lea rsi, [in2]
    call demo_one

    mov eax, SYS_exit
    xor edi, edi
    syscall

demo_one:
    push rsi
    mov rdi, STDOUT
    lea rsi, [lab]
    call print_cstr
    pop rsi
    push rsi
    mov rdi, STDOUT
    call print_cstr
    call print_nl

    pop rsi
    call atoi_hex_u128
    jc .err

    mov r12, rdi
    mov r13, rax

    mov rdi, STDOUT
    lea rsi, [ok1]
    call print_cstr
    mov rdi, r12
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [ok2]
    call print_cstr
    mov rdi, r13
    call print_hex64
    call print_nl
    ret

.err:
    mov rdi, STDOUT
    lea rsi, [bad]
    call print_cstr
    ret
