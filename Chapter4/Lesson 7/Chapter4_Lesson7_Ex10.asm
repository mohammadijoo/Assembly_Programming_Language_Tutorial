BITS 64
default rel
global _start

section .data
; Try different test strings:
s1 db "-9223372036854775808", 0         ; valid (INT64_MIN)
s2 db "9223372036854775807", 0          ; valid (INT64_MAX)
s3 db "9223372036854775808", 0          ; overflow
s4 db "-9223372036854775809", 0         ; overflow

section .text
; parse_i64:
;   RSI -> NUL-terminated string
; Returns:
;   RAX = parsed int64 (undefined on overflow in this demo)
;   RDX = error (0 ok, 1 overflow/invalid)
parse_i64:
    xor eax, eax             ; value = 0 (magnitude in RAX)
    xor edx, edx             ; error = 0
    mov r8d, 0               ; sign: 0 => +, 1 => -

    ; optional sign
    mov bl, [rsi]
    cmp bl, '-'
    jne .check_plus
    mov r8d, 1
    inc rsi
    jmp .digits

.check_plus:
    cmp bl, '+'
    jne .digits
    inc rsi

.digits:
    ; choose magnitude limit:
    ;  + : limit = 0x7FFF... (INT64_MAX)
    ;  - : limit = 0x8000... (abs(INT64_MIN))
    mov r9, 0x7FFFFFFFFFFFFFFF
    cmp r8d, 0
    je .loop
    mov r9, 0x8000000000000000

.loop:
    mov bl, [rsi]
    test bl, bl
    jz .finish

    ; must be '0'..'9'
    cmp bl, '0'
    jb .invalid
    cmp bl, '9'
    ja .invalid

    ; digit = bl - '0'
    movzx r10, bl
    sub r10, '0'

    ; overflow check: if value > (limit - digit)/10 => overflow
    ; compute tmp = limit - digit
    mov r11, r9
    sub r11, r10
    mov r12, 10
    xor edx, edx
    mov rax, rax             ; keep rax as value
    ; compare value with tmp/10 without dividing value:
    ; We'll compute q = tmp / 10 and compare value > q
    mov r13, r11
    xor edx, edx
    mov rax, r13
    div r12                   ; q in RAX (uses unsigned div)
    mov r14, rax              ; q

    ; restore value to RAX for next steps: we had overwritten it, so keep it in r15.
    ; We'll maintain the running value in r15 to avoid clobbering.
    ; First time through, r15 is not set; set it now.
    ; (This is intentionally explicit to show control flow; production code would be tighter.)
    ; We re-load current value from stack-like save in r15.
    ; If r15==0 at start and we only grow, it's fine for this demo.
    ; We'll initialize r15 in caller.
    ; (See _start below.)
    mov rax, r15              ; current value

    cmp rax, r14
    ja  .overflow

    ; value = value*10 + digit (using LEA and ADD)
    lea rax, [rax*8 + rax*2]  ; rax = value*10
    add rax, r10

    mov r15, rax              ; save running value
    inc rsi
    jmp .loop

.invalid:
    mov edx, 1
    ret

.overflow:
    mov edx, 1
    ret

.finish:
    ; Apply sign to magnitude in r15
    mov rax, r15
    cmp r8d, 0
    je .ok
    neg rax                   ; -magnitude; works for INT64_MIN because magnitude allowed 0x8000...
.ok:
    xor edx, edx
    ret

_start:
    ; Choose which string to parse:
    lea rsi, [rel s3]

    xor r15, r15              ; running magnitude storage for parse_i64
    call parse_i64

    ; exit(error)
    mov edi, edx
    mov eax, 60
    syscall
