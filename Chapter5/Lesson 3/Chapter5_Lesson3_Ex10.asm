; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
; Hard exercise solution: Levenshtein (edit) distance with DP table
; Strings are ASCII; lengths are compile-time constants for simplicity.

%define LEN_S 9
%define LEN_T 10

section .data
s db "algorithm"             ; length 9
t db "alligator!"            ; length 10

msg db "Edit distance(s,t) = ", 0

section .bss
; DP is (LEN_S+1) x (LEN_T+1) of dwords
dp resd ((LEN_S+1)*(LEN_T+1))

section .text
global _start

_start:
    ; Initialize dp[i][0] = i
    xor edi, edi              ; i
.init_col:
    mov eax, edi
    mov [dp + rdi*(LEN_T+1)*4], eax
    inc edi
    cmp edi, (LEN_S+1)
    jl .init_col

    ; Initialize dp[0][j] = j
    xor esi, esi              ; j
.init_row:
    mov eax, esi
    mov [dp + rsi*4], eax
    inc esi
    cmp esi, (LEN_T+1)
    jl .init_row

    ; DP fill:
    ; dp[i][j] = min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1] + cost)
    mov edi, 1
.i_loop:
    mov esi, 1
.j_loop:
    ; cost = (s[i-1] == t[j-1]) ? 0 : 1
    mov al, [s + rdi - 1]
    mov bl, [t + rsi - 1]
    xor ecx, ecx              ; cost
    cmp al, bl
    je .cost_ok
    mov ecx, 1
.cost_ok:

    ; idx(i,j) = i*(LEN_T+1) + j
    mov eax, edi
    imul eax, (LEN_T+1)
    add eax, esi
    mov r8d, eax              ; idx in r8d

    ; a = dp[i-1][j] + 1
    mov eax, r8d
    sub eax, (LEN_T+1)
    mov edx, [dp + rax*4]
    add edx, 1

    ; b = dp[i][j-1] + 1
    mov eax, r8d
    sub eax, 1
    mov ebx, [dp + rax*4]
    add ebx, 1

    ; c = dp[i-1][j-1] + cost
    mov eax, r8d
    sub eax, (LEN_T+2)        ; (LEN_T+1)+1
    mov eax, [dp + rax*4]
    add eax, ecx

    ; min = min(a,b,c)
    mov r9d, edx              ; min = a
    cmp ebx, r9d
    cmovl r9d, ebx
    cmp eax, r9d
    cmovl r9d, eax

    mov [dp + r8*4], r9d

    inc esi
    cmp esi, (LEN_T+1)
    jl .j_loop

    inc edi
    cmp edi, (LEN_S+1)
    jl .i_loop

    ; result = dp[LEN_S][LEN_T]
    mov eax, LEN_S
    imul eax, (LEN_T+1)
    add eax, LEN_T
    mov eax, [dp + rax*4]
    movzx rax, eax

    lea rsi, [msg]
    call print_cstr
    call print_u64
    call print_newline

    xor edi, edi
    jmp exit

; RSI = zero-terminated string
print_cstr:
    push rdx
    xor edx, edx
.len:
    cmp byte [rsi + rdx], 0
    je .emit
    inc edx
    jmp .len
.emit:
    call _write_stdout
    pop rdx
    ret

\
; ----------------------------
; Minimal I/O helpers (Linux)
; ----------------------------
%define SYS_write 1
%define SYS_exit  60

section .bss
numbuf  resb 32
chbuf   resb 1

section .text

; write(fd=1, buf=rsi, len=rdx)
_write_stdout:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

; BL = character
print_char_bl:
    mov [chbuf], bl
    lea rsi, [chbuf]
    mov edx, 1
    jmp _write_stdout

print_newline:
    mov bl, 10
    jmp print_char_bl

print_space:
    mov bl, ' '
    jmp print_char_bl

; RAX = unsigned 64-bit integer
print_u64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    lea rdi, [numbuf + 31]     ; one past last printable digit slot
    mov byte [rdi], 0

    mov rbx, 10
    cmp rax, 0
    jne .convert

    dec rdi
    mov byte [rdi], '0'
    jmp .emit

.convert:
    ; produce digits in reverse
.loop:
    xor edx, edx
    div rbx                   ; RAX = quotient, RDX = remainder
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jne .loop

.emit:
    lea rsi, [rdi]
    lea rdx, [numbuf + 31]
    sub rdx, rsi              ; len = end - start
    call _write_stdout

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; RAX = signed 64-bit integer
print_s64:
    test rax, rax
    jns .pos
    mov bl, '-'
    call print_char_bl
    neg rax
.pos:
    jmp print_u64

; Exit with status in EDI
exit:
    mov eax, SYS_exit
    syscall
