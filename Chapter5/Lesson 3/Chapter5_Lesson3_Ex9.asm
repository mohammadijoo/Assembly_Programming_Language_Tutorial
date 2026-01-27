; NASM x86-64 (Linux) — Chapter 5, Lesson 3: Nested Loops in Assembly
; Build:
;   nasm -felf64 FILE.asm -o FILE.o
;   ld -o FILE FILE.o
; Run:
;   ./FILE

bits 64
default rel
%define N 4
%define INF 0x3f3f3f3f        ; "large enough" sentinel

section .data
; dist matrix (row-major, signed dwords). INF means "no edge".
; Example directed graph:
; 0->1 (3), 0->2 (10), 1->2 (1), 2->3 (2), 1->3 (7), 3->0 (4)
dist dd  0,   3,  10, INF,
      INF,  0,   1,   7,
      INF, INF,  0,   2,
        4, INF, INF,  0

msg db "Checksum(all-pairs shortest paths) = ", 0

section .text
global _start

_start:
    ; Floyd-Warshall:
    ; for k:
    ;   for i:
    ;     for j:
    ;       dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
    ;
    ; We must avoid INF overflow by skipping if either term is INF.

    xor edi, edi              ; k
.k_loop:
    xor esi, esi              ; i
.i_loop:
    xor ecx, ecx              ; j
.j_loop:
    ; dik = dist[i][k]
    mov eax, esi
    imul eax, N
    add eax, edi
    mov edx, [dist + rax*4]   ; dik in EDX

    cmp edx, INF
    jge .next_j               ; no path i->k

    ; dkj = dist[k][j]
    mov eax, edi
    imul eax, N
    add eax, ecx
    mov ebx, [dist + rax*4]   ; dkj in EBX

    cmp ebx, INF
    jge .next_j               ; no path k->j

    ; candidate = dik + dkj
    mov eax, edx
    add eax, ebx

    ; dij = dist[i][j]
    mov r8d, esi
    imul r8d, N
    add r8d, ecx
    mov r9d, [dist + r8*4]

    cmp eax, r9d
    jge .next_j

    mov [dist + r8*4], eax

.next_j:
    inc ecx
    cmp ecx, N
    jl .j_loop

    inc esi
    cmp esi, N
    jl .i_loop

    inc edi
    cmp edi, N
    jl .k_loop

    ; checksum: sum finite dist entries (skip INF)
    xor r12, r12
    xor edi, edi              ; idx
.sum:
    mov eax, [dist + rdi*4]
    cmp eax, INF
    jge .skip
    cdqe
    add r12, rax
.skip:
    inc edi
    cmp edi, (N*N)
    jl .sum

    lea rsi, [msg]
    call print_cstr
    mov rax, r12
    call print_s64
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
