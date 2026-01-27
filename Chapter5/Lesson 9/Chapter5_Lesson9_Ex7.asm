; Chapter5_Lesson9_Ex7.asm
; VERY HARD EXERCISE SOLUTION: Token counter using an explicit FSM with computed dispatch.
;
; Goal: Count how many decimal integer tokens appear in a string.
; Token definition: a maximal run of digits ('0'..'9'). Any non-digit splits tokens.
; Example: "a12 b003c 9" has 3 integer tokens.
;
; count_int_tokens(s=rdi) -> eax (count)
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex7.asm -o ex7.o
;   ld ex7.o -o ex7

BITS 64
DEFAULT REL

SECTION .rodata
s1: db "a12 b003c 9",0
s2: db "___",0
s3: db "7",0
s4: db "99b88c777",0

SECTION .text
global _start

%define ST_OUT 0
%define ST_IN  1

; classify char in al -> bl (0=non-digit, 1=digit, 2=end)
classify:
    test    al, al
    jz      .L_end
    cmp     al, '0'
    jb      .L_nond
    cmp     al, '9'
    ja      .L_nond
    mov     bl, 1
    ret
.L_nond:
    xor     bl, bl
    ret
.L_end:
    mov     bl, 2
    ret

; Dispatch table: state x class -> handler
; index = state*3 + class  (class in {0,1,2})
SECTION .rodata
dt:
    dq .L_out_nond, .L_out_digit, .L_out_end
    dq .L_in_nond,  .L_in_digit,  .L_in_end

SECTION .text

count_int_tokens:
    xor     eax, eax        ; count
    xor     ecx, ecx        ; state = ST_OUT

.L_loop:
    mov     dl, [rdi]       ; current char
    mov     al, dl
    call    classify        ; bl = class
    movzx   edx, bl         ; class in edx

    ; idx = state*3 + class
    lea     ebx, [ecx + ecx*2]   ; state*3
    add     ebx, edx
    mov     r8, [dt + rbx*8]
    jmp     r8

; --- State handlers (each ends by advancing / returning / updating state) ---
.L_out_nond:
    ; stay OUT, advance
    inc     rdi
    jmp     .L_loop

.L_out_digit:
    ; OUT -> IN, increment count, advance
    inc     eax
    mov     ecx, ST_IN
    inc     rdi
    jmp     .L_loop

.L_out_end:
    ret

.L_in_nond:
    ; IN -> OUT, advance
    mov     ecx, ST_OUT
    inc     rdi
    jmp     .L_loop

.L_in_digit:
    ; stay IN, advance
    inc     rdi
    jmp     .L_loop

.L_in_end:
    ret

_start:
    ; s1 expects 3
    lea     rdi, [s1]
    call    count_int_tokens
    cmp     eax, 3
    jne     .L_fail

    ; s2 expects 0
    lea     rdi, [s2]
    call    count_int_tokens
    test    eax, eax
    jne     .L_fail

    ; s3 expects 1
    lea     rdi, [s3]
    call    count_int_tokens
    cmp     eax, 1
    jne     .L_fail

    ; s4 expects 3
    lea     rdi, [s4]
    call    count_int_tokens
    cmp     eax, 3
    jne     .L_fail

    xor     edi, edi
    mov     eax, 60
    syscall

.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall
