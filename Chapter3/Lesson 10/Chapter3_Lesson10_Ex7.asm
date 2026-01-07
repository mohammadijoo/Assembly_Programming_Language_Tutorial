; Chapter3_Lesson10_Ex7.asm
; BMI1 BEXTR vs shift+mask fallback with CPUID feature check.
; CPUID.(EAX=7, ECX=0):EBX bit 3 indicates BMI1 support.
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex7.asm && ld -o ex7 Chapter3_Lesson10_Ex7.o
; Run:      ./ex7

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_src:     db "src      = ",0
msg_ctrl:    db "ctrl     = ",0
msg_bextr:   db "BEXTR    = ",0
msg_fallback:db "fallback = ",0
msg_no:      db "BMI1 not supported; used fallback",10,0

hexdigits: db "0123456789ABCDEF"

SECTION .bss
hexbuf: resb 19

SECTION .text

write_buf:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

print_cstr:
    xor rdx, rdx
.count:
    cmp byte [rsi+rdx], 0
    je .go
    inc rdx
    jmp .count
.go:
    jmp write_buf

print_hex64:
    lea rsi, [rel hexbuf]
    mov byte [rsi+0], '0'
    mov byte [rsi+1], 'x'
    mov rax, rdi
    lea rbx, [rel hexdigits]
    mov rcx, 16
.loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx+rdx]
    mov [rsi+1+rcx], dl
    shr rax, 4
    dec rcx
    jnz .loop
    mov byte [rsi+18], 10
    mov rdx, 19
    jmp write_buf

; has_bmi1() -> ZF=0 if supported, ZF=1 if not (for convenience)
has_bmi1:
    ; Check CPUID leaf 7 availability
    mov eax, 0
    cpuid
    cmp eax, 7
    jb .no

    mov eax, 7
    xor ecx, ecx
    cpuid
    bt ebx, 3               ; BMI1 bit
    jc .yes
.no:
    xor eax, eax            ; return 0
    test eax, eax           ; ZF=1
    ret
.yes:
    mov eax, 1
    test eax, eax           ; ZF=0
    ret

_start:
    ; Example source value
    mov rbx, 0xF0E1D2C3B4A59687

    ; Extract a 10-bit field at lsb=17:
    ; control = (len<<8) | start  where len=10, start=17
    mov ecx, (10 << 8) | 17

    lea rsi, [rel msg_src]
    call print_cstr
    mov rdi, rbx
    call print_hex64

    lea rsi, [rel msg_ctrl]
    call print_cstr
    mov rdi, rcx
    call print_hex64

    call has_bmi1
    jz .fallback_path

    ; BEXTR rax, rbx, rcx
    ; rax <- extract bits [start +: len] from rbx (unsigned extract)
    bextr rax, rbx, rcx
    lea rsi, [rel msg_bextr]
    call print_cstr
    mov rdi, rax
    call print_hex64
    jmp .done

.fallback_path:
    lea rsi, [rel msg_no]
    call print_cstr

    ; Fallback: (rbx >> start) & ((1<<len)-1)
    mov rax, rbx
    mov cl, 17
    shr rax, cl

    mov rdx, 1
    mov cl, 10
    shl rdx, cl
    dec rdx

    and rax, rdx
    lea rsi, [rel msg_fallback]
    call print_cstr
    mov rdi, rax
    call print_hex64

.done:
    xor edi, edi
    mov eax, SYS_exit
    syscall
