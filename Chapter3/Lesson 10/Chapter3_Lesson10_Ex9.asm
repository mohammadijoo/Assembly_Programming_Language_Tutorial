; Chapter3_Lesson10_Ex9.asm
; Programming Exercise 1 (Solution):
; Generic variable-width get/set bitfield routines for 64-bit packed descriptors.
;
; Descriptor layout (bits, little-endian word):
; [63:32] checksum (32)
; [31:16] length   (16)
; [15:7]  owner    (9)
; [6:4]   perms    (3)
; [3:0]   type     (4)
;
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex9.asm && ld -o ex9 Chapter3_Lesson10_Ex9.o
; Run:      ./ex9

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .rodata
msg_desc:   db "desc     = ",0
msg_type:   db "type     = ",0
msg_perms:  db "perms    = ",0
msg_owner:  db "owner    = ",0
msg_len:    db "length   = ",0
msg_ck:     db "checksum = ",0
msg_new:    db "desc(new)= ",0
hexdigits:  db "0123456789ABCDEF"

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

;--------------------------------------------
; bf_mask64(width=EDX) -> RAX
; width in 0..64
;--------------------------------------------
bf_mask64:
    test edx, edx
    jz .zero
    cmp edx, 64
    je .all
    mov rax, 1
    mov ecx, edx
    shl rax, cl
    dec rax
    ret
.all:
    mov rax, -1
    ret
.zero:
    xor rax, rax
    ret

;--------------------------------------------
; bf_get64(value=RDI, lsb=ESI, width=EDX) -> RAX
;--------------------------------------------
bf_get64:
    push rbx
    mov rbx, rdi            ; save value
    call bf_mask64          ; rax=mask(width)
    mov r8, rax             ; mask
    mov rax, rbx
    mov ecx, esi
    shr rax, cl
    and rax, r8
    pop rbx
    ret

;--------------------------------------------
; bf_set64(base=RDI, value=RSI, lsb=EDX, width=ECX) -> RAX
; Returns updated base in RAX.
;--------------------------------------------
bf_set64:
    push rbx
    push r12
    mov rbx, rdi            ; base
    mov r12, rsi            ; value

    ; mask = (width==64) ? -1 : (1<<width)-1
    mov edx, ecx
    call bf_mask64
    mov r8, rax             ; field_mask_lowbits

    ; field_mask_shifted = field_mask_lowbits << lsb
    mov r9, r8
    mov ecx, edx            ; restore width? (edx currently width, but we need lsb)
    ; We'll reload lsb from EDX (original lsb stored in EDX by caller).
    ; However EDX was overwritten; so we require lsb in EAX? No.
    ; Fix: treat lsb as R10D argument computed by caller before call.
    ; To keep a stable ABI for this exercise, we will pass lsb in R10D.
    ; (See _start for call sites.)
    ;
    ; r10d = lsb
    mov ecx, r10d
    shl r9, cl              ; shift mask into position

    ; clear those bits in base: base &= ~field_mask_shifted
    not r9
    and rbx, r9

    ; insert: (value & field_mask_lowbits) << lsb
    and r12, r8
    mov ecx, r10d
    shl r12, cl
    or rbx, r12

    mov rax, rbx
    pop r12
    pop rbx
    ret

_start:
    ; Build an example descriptor.
    ; type=0xB, perms=0x5, owner=0x12A, length=0x1337, checksum=0xDEADBEEF
    mov rdi, 0
    mov rsi, 0xB
    mov r10d, 0              ; lsb
    mov ecx, 4               ; width
    call bf_set64
    mov rdi, rax
    mov rsi, 0x5
    mov r10d, 4
    mov ecx, 3
    call bf_set64
    mov rdi, rax
    mov rsi, 0x12A
    mov r10d, 7
    mov ecx, 9
    call bf_set64
    mov rdi, rax
    mov rsi, 0x1337
    mov r10d, 16
    mov ecx, 16
    call bf_set64
    mov rdi, rax
    mov rsi, 0xDEADBEEF
    mov r10d, 32
    mov ecx, 32
    call bf_set64
    mov rbx, rax             ; descriptor

    lea rsi, [rel msg_desc]
    call print_cstr
    mov rdi, rbx
    call print_hex64

    ; Extract and print fields
    lea rsi, [rel msg_type]
    call print_cstr
    mov rdi, rbx
    mov esi, 0
    mov edx, 4
    call bf_get64
    mov rdi, rax
    call print_hex64

    lea rsi, [rel msg_perms]
    call print_cstr
    mov rdi, rbx
    mov esi, 4
    mov edx, 3
    call bf_get64
    mov rdi, rax
    call print_hex64

    lea rsi, [rel msg_owner]
    call print_cstr
    mov rdi, rbx
    mov esi, 7
    mov edx, 9
    call bf_get64
    mov rdi, rax
    call print_hex64

    lea rsi, [rel msg_len]
    call print_cstr
    mov rdi, rbx
    mov esi, 16
    mov edx, 16
    call bf_get64
    mov rdi, rax
    call print_hex64

    lea rsi, [rel msg_ck]
    call print_cstr
    mov rdi, rbx
    mov esi, 32
    mov edx, 32
    call bf_get64
    mov rdi, rax
    call print_hex64

    ; Update perms to 0x2 and length to 0x0042
    mov rdi, rbx
    mov rsi, 0x2
    mov r10d, 4
    mov ecx, 3
    call bf_set64
    mov rdi, rax
    mov rsi, 0x0042
    mov r10d, 16
    mov ecx, 16
    call bf_set64
    mov rbx, rax

    lea rsi, [rel msg_new]
    call print_cstr
    mov rdi, rbx
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall
