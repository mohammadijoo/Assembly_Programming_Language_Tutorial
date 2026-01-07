bits 64
default rel

global _start

; Chapter 3, Lesson 7, Exercise Solution 4
; Reverse a UTF-8 string by code points (not by bytes).
; Strategy:
;   - Find end pointer.
;   - Walk backward to previous code point start:
;       while byte is 10xxxxxx (continuation), move left.
;   - Copy that whole code point bytes to output buffer.
; This preserves each UTF-8 sequence, but reverses the sequence order.
;
; This solution uses an output buffer (not in-place), which is the typical
; engineering approach because UTF-8 is variable-length.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    ; UTF-8: "ab€😀Z\n"
    s: db 'a','b',0xE2,0x82,0xAC,0xF0,0x9F,0x98,0x80,'Z',10,0
    s_len: equ $ - s - 1

section .bss
    out: resb 128

section .text

_start:
    lea rdi, [s]
    mov esi, s_len
    lea rdx, [out]
    call utf8_reverse_to_out
    test eax, eax
    jz .err

    ; write reversed string
    mov edx, eax
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [out]
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

.err:
    mov edi, 1
    mov eax, SYS_exit
    syscall

; -------------------------------------------------------
; utf8_reverse_to_out
; IN:  RDI = input ptr, ESI = input length
;      RDX = output ptr (capacity >= input length)
; OUT: EAX = bytes written, or 0 on error
; -------------------------------------------------------
utf8_reverse_to_out:
    push rbx
    push r12
    push r13

    mov r12, rdi              ; in base
    mov r13, rdx              ; out base
    lea rbx, [r12 + rsi]      ; in_end
    mov r9, rbx               ; cursor = in_end
    mov r8, rdx               ; out cursor

    ; quick structural validation while reversing:
    ; we only ensure that each backward-scanned sequence has a plausible lead byte.
    ; For production, combine with a forward validator (see Exercise Solution 1).

.loop:
    cmp r9, r12
    jbe .done

    ; move left by at least one byte
    dec r9

    ; skip continuation bytes (10xxxxxx)
.cont_back:
    cmp r9, r12
    jb  .bad
    mov al, [r9]
    and al, 0xC0
    cmp al, 0x80
    jne .at_lead
    dec r9
    jmp .cont_back

.at_lead:
    ; r9 points to lead byte of the code point; determine its length.
    movzx eax, byte [r9]
    cmp al, 0x80
    jb  .len1
    cmp al, 0xC2
    jb  .bad
    cmp al, 0xDF
    jbe .len2
    cmp al, 0xE0
    jb  .bad
    cmp al, 0xEF
    jbe .len3
    cmp al, 0xF0
    jb  .bad
    cmp al, 0xF4
    jbe .len4
    jmp .bad

.len1:
    mov ecx, 1
    jmp .copy
.len2:
    mov ecx, 2
    jmp .copy
.len3:
    mov ecx, 3
    jmp .copy
.len4:
    mov ecx, 4

.copy:
    ; ensure the code point is entirely within the original buffer:
    ; start=r9, end=start+len <= in_end
    lea r10, [r9 + rcx]
    cmp r10, rbx
    ja  .bad

    ; copy ecx bytes from [r9] to out cursor
    mov r11d, ecx
.copy_loop:
    mov al, [r9]
    mov [r8], al
    inc r9
    inc r8
    dec r11d
    jnz .copy_loop

    ; restore r9 to start position for next iteration:
    ; after copy_loop, r9 advanced to end of code point; set r9 back to start
    sub r9, rcx

    ; next iteration continues from start of this code point
    jmp .loop

.done:
    ; bytes written = out_cursor - out_base
    mov rax, r8
    sub rax, r13
    mov eax, eax
    jmp .ret

.bad:
    xor eax, eax

.ret:
    pop r13
    pop r12
    pop rbx
    ret
