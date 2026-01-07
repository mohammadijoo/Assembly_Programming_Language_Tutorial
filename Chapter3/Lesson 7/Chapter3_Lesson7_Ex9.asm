bits 64
default rel

global _start

; Chapter 3, Lesson 7, Exercise Solution 1
; UTF-8 validator with error index and coarse error class.
;
; validate_utf8(rdi=ptr, rsi=len) -> eax=status, edx=error_index
; status:
;   0 = ok
;   1 = truncated sequence
;   2 = invalid leading byte
;   3 = invalid continuation byte
;   4 = overlong encoding
;   5 = surrogate encoded
;   6 = out-of-range code point
;
; Demo validates a "good" buffer and a "bad" buffer.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
    good: db "OK: ", 0xE2,0x82,0xAC, " and ", 0xF0,0x9F,0x98,0x80, 10
    good_len: equ $ - good

    ; bad contains:
    ;  - 0xC0 0xAF (overlong encoding of '/')
    ;  - 0xED 0xA0 0x80 (surrogate U+D800)
    bad:  db "BAD: ", 0xC0,0xAF, " ", 0xED,0xA0,0x80, 10
    bad_len: equ $ - bad

    ok_msg:  db "VALID\n"
    ok_len:  equ $ - ok_msg

    err_msg: db "ERROR status=0x?? index=0x??\n"
    err_len: equ $ - err_msg

    hex_lut: db "0123456789ABCDEF"

section .text

_start:
    ; Validate good
    lea rdi, [good]
    mov esi, good_len
    call validate_utf8
    test eax, eax
    jnz .print_err
    lea rdi, [ok_msg]
    mov edx, ok_len
    call write_stdout

    ; Validate bad
    lea rdi, [bad]
    mov esi, bad_len
    call validate_utf8
    test eax, eax
    jnz .print_err2
    lea rdi, [ok_msg]
    mov edx, ok_len
    call write_stdout
    jmp .exit

.print_err:
    ; expected not taken for "good"
    jmp .render_err

.print_err2:
    ; expected taken for "bad"
.render_err:
    ; Patch err_msg "??" fields with status and index low byte in hex (for demo).
    ; status at positions: "status=0x??" -> '?' at offsets 12,13
    ; index  at positions: "index=0x??"  -> '?' at offsets 22,23
    mov ebx, eax
    mov eax, ebx
    lea rdi, [err_msg]
    call patch_hex_at_12

    mov eax, edx
    lea rdi, [err_msg]
    call patch_hex_at_22

    lea rdi, [err_msg]
    mov edx, err_len
    call write_stdout

.exit:
    xor edi, edi
    mov eax, SYS_exit
    syscall

; --------------------------------------------
write_stdout:
    mov eax, SYS_write
    mov edi, STDOUT
    mov rsi, rdi
    syscall
    ret

; --------------------------------------------
; patch_hex_at_12 / patch_hex_at_22
; IN: EAX = byte value, RDI = base of string
; --------------------------------------------
patch_hex_at_12:
    lea r8, [hex_lut]
    mov ecx, eax
    and ecx, 0xFF
    mov edx, ecx
    shr edx, 4
    and ecx, 0x0F
    mov dl, [r8 + rdx]
    mov [rdi + 12], dl
    mov dl, [r8 + rcx]
    mov [rdi + 13], dl
    ret

patch_hex_at_22:
    lea r8, [hex_lut]
    mov ecx, eax
    and ecx, 0xFF
    mov edx, ecx
    shr edx, 4
    and ecx, 0x0F
    mov dl, [r8 + rdx]
    mov [rdi + 22], dl
    mov dl, [r8 + rcx]
    mov [rdi + 23], dl
    ret

; --------------------------------------------
; validate_utf8
; IN:  RDI=ptr, ESI=len
; OUT: EAX=status, EDX=error_index
; --------------------------------------------
validate_utf8:
    xor eax, eax
    xor edx, edx

    mov r8, rdi        ; base
    mov r9d, esi       ; remaining length
    xor r10d, r10d     ; index

.loop:
    cmp r10d, r9d
    jae .ok

    movzx ecx, byte [r8 + r10]
    cmp cl, 0x80
    jb .step1

    ; 2-byte lead (C2..DF)
    cmp cl, 0xC2
    jb  .bad_lead
    cmp cl, 0xDF
    jbe .need1_cont

    ; 3-byte lead (E0..EF)
    cmp cl, 0xE0
    jb  .bad_lead
    cmp cl, 0xEF
    jbe .need2_cont

    ; 4-byte lead (F0..F4)
    cmp cl, 0xF0
    jb  .bad_lead
    cmp cl, 0xF4
    jbe .need3_cont

    jmp .bad_lead

.step1:
    inc r10d
    jmp .loop

.need1_cont:
    ; truncated?
    mov eax, 1
    lea edx, [r10d]
    cmp r10d, r9d
    jae .ret
    lea eax, [r10d + 1]
    cmp eax, r9d
    jae .ret_trunc

    movzx ebx, byte [r8 + r10 + 1]
    call cont_ok
    test eax, eax
    jz .bad_cont

    add r10d, 2
    xor eax, eax
    jmp .loop

.need2_cont:
    lea eax, [r10d + 2]
    cmp eax, r9d
    jae .ret_trunc

    movzx ebx, byte [r8 + r10 + 1]
    movzx esi, byte [r8 + r10 + 2]

    ; continuation checks
    mov eax, ebx
    call cont_ok
    test eax, eax
    jz .bad_cont
    mov eax, esi
    call cont_ok
    test eax, eax
    jz .bad_cont

    ; constraints: E0 b1 >= A0 (avoid overlong)
    ;             ED b1 <= 9F (avoid surrogates)
    movzx eax, byte [r8 + r10]
    cmp al, 0xE0
    jne .chk_ed
    cmp bl, 0xA0
    jb  .bad_overlong
.chk_ed:
    cmp al, 0xED
    jne .ok3
    cmp bl, 0x9F
    ja  .bad_surrogate
.ok3:
    add r10d, 3
    xor eax, eax
    jmp .loop

.need3_cont:
    lea eax, [r10d + 3]
    cmp eax, r9d
    jae .ret_trunc

    movzx ebx, byte [r8 + r10 + 1]
    movzx esi, byte [r8 + r10 + 2]
    movzx edi, byte [r8 + r10 + 3]

    mov eax, ebx
    call cont_ok
    test eax, eax
    jz .bad_cont
    mov eax, esi
    call cont_ok
    test eax, eax
    jz .bad_cont
    mov eax, edi
    call cont_ok
    test eax, eax
    jz .bad_cont

    movzx eax, byte [r8 + r10]
    cmp al, 0xF0
    jne .chk_f4
    cmp bl, 0x90
    jb  .bad_overlong
.chk_f4:
    cmp al, 0xF4
    jne .ok4
    cmp bl, 0x8F
    ja  .bad_range
.ok4:
    add r10d, 4
    xor eax, eax
    jmp .loop

.ret_trunc:
    mov eax, 1
    mov edx, r10d
    ret

.bad_lead:
    mov eax, 2
    mov edx, r10d
    ret

.bad_cont:
    mov eax, 3
    mov edx, r10d
    ret

.bad_overlong:
    mov eax, 4
    mov edx, r10d
    ret

.bad_surrogate:
    mov eax, 5
    mov edx, r10d
    ret

.bad_range:
    mov eax, 6
    mov edx, r10d
    ret

.ok:
    xor eax, eax
    xor edx, edx
.ret:
    ret

; cont_ok: checks whether AL is a UTF-8 continuation byte (10xxxxxx)
; IN:  EAX = byte
; OUT: EAX = 1 if ok else 0
cont_ok:
    and eax, 0xC0
    cmp eax, 0x80
    sete al
    movzx eax, al
    ret
