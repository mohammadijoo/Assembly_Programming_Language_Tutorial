bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 5
; UTF-8 decoder (one code point at a time) with structural validation and key semantic checks:
; - rejects invalid leading bytes
; - rejects overlong encodings using constrained ranges
; - rejects surrogates (U+D800..U+DFFF)
; - rejects out-of-range (> U+10FFFF)
;
; Demo: decodes a fixed UTF-8 byte sequence and prints code points as "U+XXXXXXXX\n".

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    ; "A ¢ € 😀"
    s:  db 'A', ' ', 0xC2,0xA2, ' ', 0xE2,0x82,0xAC, ' ', 0xF0,0x9F,0x98,0x80, 10, 0
    s_len: equ $ - s - 1

    hex_lut: db "0123456789ABCDEF"

section .bss
    line: resb 16  ; "U+XXXXXXXX\n" (11 bytes)

section .text

_start:
    lea rbx, [s]
    lea r13, [s + s_len]     ; end pointer (excluding final 0)

.loop:
    cmp rbx, r13
    jae .done

    mov rdi, rbx
    mov rsi, r13
    call utf8_decode_one
    test ecx, ecx
    jnz .error

    ; EAX=codepoint, EDX=bytes_consumed
    mov r14d, eax            ; save code point
    add rbx, rdx             ; advance input pointer

    ; print "U+XXXXXXXX\n"
    mov byte [line+0], 'U'
    mov byte [line+1], '+'
    mov eax, r14d
    call u32_to_hex8_at2     ; writes at line[2..9]
    mov byte [line+10], 10

    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [line]
    mov edx, 11
    syscall

    jmp .loop

.error:
    ; On error, exit with status 2.
    mov edi, 2
    mov eax, SYS_exit
    syscall

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; utf8_decode_one
; IN:  RDI = ptr to current byte
;      RSI = ptr to end (one past last valid byte)
; OUT: EAX = code point (valid if ECX=0)
;      EDX = bytes consumed
;      ECX = status (0 ok, nonzero error)
; -------------------------------------------------------
utf8_decode_one:
    xor ecx, ecx
    xor edx, edx

    cmp rdi, rsi
    jae .fail_trunc

    movzx eax, byte [rdi]
    cmp al, 0x80
    jb  .one

    ; 2-byte lead: 0xC2..0xDF (0xC0/0xC1 would be overlong)
    cmp al, 0xC2
    jb  .fail_lead
    cmp al, 0xDF
    jbe .two

    ; 3-byte lead: 0xE0..0xEF
    cmp al, 0xE0
    jb  .fail_lead
    cmp al, 0xEF
    jbe .three

    ; 4-byte lead: 0xF0..0xF4 (0xF5..0xFF out of range)
    cmp al, 0xF0
    jb  .fail_lead
    cmp al, 0xF4
    jbe .four

    jmp .fail_lead

.one:
    mov edx, 1
    ret

.two:
    ; need 2 bytes
    lea r8, [rdi+2]
    cmp r8, rsi
    ja  .fail_trunc

    movzx ebx, byte [rdi+1]
    ; continuation must be 10xxxxxx
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont

    ; cp = ((b0 & 0x1F) << 6) | (b1 & 0x3F)
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

    ; validate continuation
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont
    test r9b, 0xC0
    cmp r9b, 0x80
    jne .fail_cont

    ; extra constraints to reject overlong and surrogates:
    ; if lead == 0xE0 then b1 >= 0xA0
    ; if lead == 0xED then b1 <= 0x9F  (prevents U+D800..U+DFFF)
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

    ; validate continuation
    test bl, 0xC0
    cmp bl, 0x80
    jne .fail_cont
    test r9b, 0xC0
    cmp r9b, 0x80
    jne .fail_cont
    test r10b, 0xC0
    cmp r10b, 0x80
    jne .fail_cont

    ; constraints to reject overlong and out-of-range:
    ; if lead == 0xF0 then b1 >= 0x90 (avoid overlong)
    ; if lead == 0xF4 then b1 <= 0x8F (stay <= U+10FFFF)
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

.fail_trunc:
    mov ecx, 1
    ret
.fail_lead:
    mov ecx, 2
    ret
.fail_cont:
    mov ecx, 3
    ret
.fail_overlong:
    mov ecx, 4
    ret
.fail_surrogate:
    mov ecx, 5
    ret
.fail_range:
    mov ecx, 6
    ret

; -------------------------------------------------------
; u32_to_hex8_at2
; IN:  EAX = value
; OUT: writes 8 hex digits to line[2..9]
; Clobbers: rax, rcx, rdx, r8, r11
; -------------------------------------------------------
u32_to_hex8_at2:
    lea r8, [hex_lut]
    mov ecx, 8
    lea r11, [line+2+7]     ; write backwards

.loop:
    mov edx, eax
    and edx, 0x0F
    mov dl, [r8 + rdx]
    mov [r11], dl
    shr eax, 4
    dec r11
    dec ecx
    jnz .loop
    ret
