; Chapter 2 - Lesson 7 (Execution Flow) - Exercise Solution 2
; Very hard: Identifier validator via explicit state machine.
; Accept: [A-Za-z_] [A-Za-z0-9_]* and reject otherwise.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex11.asm -o ex11.o
;   ld ex11.o -o ex11

BITS 64
DEFAULT REL

%include "Chapter2_Lesson7_Ex5.asm"

GLOBAL _start

SECTION .data
; Change test strings as needed.
s_ok   db "hello_world42", 0
s_bad1 db "42start", 0
s_bad2 db "no-dash", 0

msg_ok  db "ACCEPT", 10
len_ok  equ $-msg_ok
msg_bad db "REJECT", 10
len_bad equ $-msg_bad

SECTION .text
_start:
    lea rsi, [s_ok]         ; test string pointer
    call is_identifier
    test eax, eax
    jz   .reject
    PRINT msg_ok, len_ok
    EXIT 0

.reject:
    PRINT msg_bad, len_bad
    EXIT 0

; int is_identifier(const char *s)
; Input: RSI -> NUL-terminated string
; Output: EAX=1 if valid identifier else 0
is_identifier:
    ; State 0: expect first char (letter or underscore)
    ; State 1: subsequent chars (letter/digit/underscore)
    xor eax, eax            ; state = 0 in AL
    xor ecx, ecx            ; seen_any = 0 (used to forbid empty)

.next_char:
    mov bl, byte [rsi]
    cmp bl, 0
    je  .end

    ; Dispatch on state in AL
    test al, al
    jz   .state0
    jmp  .state1

.state0:
    ; first char: [A-Za-z_] only
    call class_letter_or_underscore
    test eax, eax
    jz   .invalid
    mov al, 1               ; state = 1
    mov ecx, 1              ; seen_any = 1
    inc rsi
    jmp .next_char

.state1:
    ; subsequent chars: [A-Za-z0-9_]
    call class_letter_digit_or_underscore
    test eax, eax
    jz   .invalid
    inc rsi
    jmp .next_char

.end:
    test ecx, ecx
    jz   .invalid           ; empty string rejected
    mov eax, 1
    ret

.invalid:
    xor eax, eax
    ret

; EAX=1 if BL in [A-Za-z_] else 0
class_letter_or_underscore:
    cmp bl, '_'
    je  .yes

    cmp bl, 'A'
    jb  .no
    cmp bl, 'Z'
    jbe .yes

    cmp bl, 'a'
    jb  .no
    cmp bl, 'z'
    jbe .yes

.no:
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

; EAX=1 if BL in [A-Za-z0-9_] else 0
class_letter_digit_or_underscore:
    cmp bl, '_'
    je  .yes

    cmp bl, '0'
    jb  .letter_part
    cmp bl, '9'
    jbe .yes

.letter_part:
    cmp bl, 'A'
    jb  .no
    cmp bl, 'Z'
    jbe .yes

    cmp bl, 'a'
    jb  .no
    cmp bl, 'z'
    jbe .yes

.no:
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret
