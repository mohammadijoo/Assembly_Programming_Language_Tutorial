bits 64
default rel

global _start

; Chapter 3, Lesson 7, Exercise Solution 3
; Transcode UTF-8 -> UTF-16LE with validation.
;
; utf8_to_utf16le(rdi=in_ptr, rsi=in_len, rdx=out_ptr, rcx=out_units_cap)
;   -> rax=units_written, r8d=status (0 ok), r9d=error_index
;
; Demo converts a UTF-8 buffer containing "A € 😀\n", then dumps UTF-16LE units as hex.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    in: db 'A',' ',0xE2,0x82,0xAC,' ',0xF0,0x9F,0x98,0x80,10
    in_len: equ $ - in

    hex_lut: db "0123456789ABCDEF"

section .bss
    out_u16:  resw 64
    line:     resb 8

section .text

_start:
    lea rdi, [in]
    mov esi, in_len
    lea rdx, [out_u16]
    mov ecx, 64
    call utf8_to_utf16le
    test r8d, r8d
    jnz .err

    ; dump each UTF-16 unit as "HHHH\n"
    xor ebx, ebx
.dump:
    cmp rbx, rax
    jae .done

    movzx eax, word [out_u16 + rbx*2]
    call u16_to_hex4_line

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [line]
    mov edx, 5
    syscall

    inc rbx
    jmp .dump

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall

.err:
    mov edi, 1
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; u16_to_hex4_line
; IN:  AX = value
; OUT: line[0..3] hex, line[4]='\n'
; -------------------------------------------------------
u16_to_hex4_line:
    lea r8, [hex_lut]
    movzx eax, ax
    mov ecx, 4
    lea rbx, [line+3]
.loop:
    mov edx, eax
    and edx, 0x0F
    mov dl, [r8 + rdx]
    mov [rbx], dl
    shr eax, 4
    dec rbx
    dec ecx
    jnz .loop
    mov byte [line+4], 10
    ret

; -------------------------------------------------------
; utf8_to_utf16le
; IN:  RDI=in_ptr, ESI=in_len, RDX=out_ptr, ECX=cap_units
; OUT: RAX=units_written, R8D=status, R9D=error_index
; status:
;   0 ok
;   1 invalid UTF-8 (decoder error)
;   5 surrogate (should not happen if decoder is correct)
;   7 insufficient output space
; -------------------------------------------------------
utf8_to_utf16le:
    xor r15d, r15d        ; units_written
    xor r8d, r8d          ; status
    xor r9d, r9d          ; error_index

    mov r10, rdi          ; base in
    mov r11d, esi         ; len
    mov r12, rdx          ; out base
    mov r13d, ecx         ; cap_units
    xor r14d, r14d        ; i (byte index)

.loop:
    cmp r14d, r11d
    jae .ok

    ; decode one code point
    lea rdi, [r10 + r14]
    lea rsi, [r10 + r11]
    call utf8_decode_one
    test ecx, ecx
    jnz .dec_err

    mov ebx, eax          ; code point
    add r14d, edx         ; consume bytes

    ; if cp <= 0xFFFF, write one unit (reject surrogate range)
    cmp ebx, 0xFFFF
    jbe .one_unit

    ; else surrogate pair (2 units)
    lea eax, [r15d + 2]
    cmp eax, r13d
    ja  .no_space

    ; cp' = cp - 0x10000
    sub ebx, 0x10000

    ; hi = 0xD800 + (cp' >> 10)
    mov edx, ebx
    shr edx, 10
    add edx, 0xD800

    ; lo = 0xDC00 + (cp' & 0x3FF)
    and ebx, 0x3FF
    add ebx, 0xDC00

    mov word [r12 + r15*2], dx
    mov word [r12 + r15*2 + 2], bx
    add r15d, 2
    jmp .loop

.one_unit:
    cmp bx, 0xD800
    jb  .one_ok
    cmp bx, 0xDFFF
    jbe .surrogate
.one_ok:
    lea eax, [r15d + 1]
    cmp eax, r13d
    ja  .no_space

    mov word [r12 + r15*2], bx
    inc r15d
    jmp .loop

.ok:
    mov eax, r15d
    xor r8d, r8d
    ret

.no_space:
    xor eax, eax
    mov r8d, 7
    mov r9d, r14d
    ret

.dec_err:
    xor eax, eax
    mov r8d, 1
    mov r9d, r14d
    ret

.surrogate:
    xor eax, eax
    mov r8d, 5
    mov r9d, r14d
    ret

; -------------------------------------------------------
; utf8_decode_one (compact decoder, like Example 5)
; IN:  RDI=ptr, RSI=end
; OUT: EAX=codepoint, EDX=bytes, ECX=status (0 ok)
; -------------------------------------------------------
utf8_decode_one:
    xor ecx, ecx
    xor edx, edx

    cmp rdi, rsi
    jae .fail_trunc

    movzx eax, byte [rdi]
    cmp al, 0x80
    jb  .one

    cmp al, 0xC2
    jb  .fail_lead
    cmp al, 0xDF
    jbe .two

    cmp al, 0xE0
    jb  .fail_lead
    cmp al, 0xEF
    jbe .three

    cmp al, 0xF0
    jb  .fail_lead
    cmp al, 0xF4
    jbe .four

    jmp .fail_lead

.one:
    mov edx, 1
    ret

.two:
    lea r8, [rdi+2]
    cmp r8, rsi
    ja  .fail_trunc
    movzx ebx, byte [rdi+1]
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont
    and eax, 0x1F
    shl eax, 6
    and ebx, 0x3F
    or  eax, ebx
    mov edx, 2
    ret

.three:
    lea r8, [rdi+3]
    cmp r8, rsi
    ja  .fail_trunc
    movzx ebx, byte [rdi+1]
    movzx r9d, byte [rdi+2]
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont
    test r9b, 0xC0
    cmp r9b, 0x80
    jne .fail_cont
    cmp al, 0xE0
    jne .chk_ed
    cmp bl, 0xA0
    jb  .fail_overlong
.chk_ed:
    cmp al, 0xED
    jne .assemble3
    cmp bl, 0x9F
    ja  .fail_surrogate
.assemble3:
    and eax, 0x0F
    shl eax, 12
    mov ecx, ebx
    and ecx, 0x3F
    shl ecx, 6
    or  eax, ecx
    mov ecx, r9d
    and ecx, 0x3F
    or  eax, ecx
    xor ecx, ecx
    mov edx, 3
    ret

.four:
    lea r8, [rdi+4]
    cmp r8, rsi
    ja  .fail_trunc
    movzx ebx, byte [rdi+1]
    movzx r9d, byte [rdi+2]
    movzx r10d, byte [rdi+3]
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont
    test r9b, 0xC0
    cmp r9b, 0x80
    jne .fail_cont
    test r10b, 0xC0
    cmp r10b, 0x80
    jne .fail_cont
    cmp al, 0xF0
    jne .chk_f4
    cmp bl, 0x90
    jb  .fail_overlong
.chk_f4:
    cmp al, 0xF4
    jne .assemble4
    cmp bl, 0x8F
    ja  .fail_range
.assemble4:
    and eax, 0x07
    shl eax, 18
    mov ecx, ebx
    and ecx, 0x3F
    shl ecx, 12
    or  eax, ecx
    mov ecx, r9d
    and ecx, 0x3F
    shl ecx, 6
    or  eax, ecx
    mov ecx, r10d
    and ecx, 0x3F
    or  eax, ecx
    xor ecx, ecx
    mov edx, 4
    ret

.fail_trunc:     mov ecx, 1  ; truncated
                 ret
.fail_lead:      mov ecx, 2  ; bad lead
                 ret
.fail_cont:      mov ecx, 3  ; bad cont
                 ret
.fail_overlong:  mov ecx, 4  ; overlong
                 ret
.fail_surrogate: mov ecx, 5  ; surrogate
                 ret
.fail_range:     mov ecx, 6  ; range
                 ret
