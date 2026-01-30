; Chapter7_Lesson9_Ex9.asm
; Compute a simple external-fragmentation metric on the coalescing allocator:
;   ext_frag_pct = 100 * (total_free - largest_free) / total_free
; (0% means all free memory is in one contiguous block.)
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex9.asm -o ex9.o
;   gcc ex9.o -o ex9
; Run:
;   ./ex9

default rel
global main
extern printf

%define POOL_BYTES 8192
%define ALIGN      16
%define HDR_BYTES  8
%define FTR_BYTES  8
%define OVERHEAD   (HDR_BYTES + FTR_BYTES)
%define MIN_BLOCK  32
%define FLAG_ALLOC 1

section .bss
pool: resb POOL_BYTES
ptrs: resq 32

section .rodata
fmt_stats: db "total_free=%llu  largest_free=%llu  ext_frag=%llu%%", 10, 0
fmt_msg: db "%s", 10, 0
m1: db "Stats after scattering frees:", 0

section .text
align_up_16:
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

heap_init:
    lea rbx, [pool]
    mov rax, POOL_BYTES
    and rax, -ALIGN
    mov [rbx], rax
    lea rdx, [rbx + rax - FTR_BYTES]
    mov [rdx], rax
    ret

heap_malloc:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    call align_up_16
    add rax, OVERHEAD
    mov r12, rax

    lea rbx, [pool]
    lea r14, [pool + POOL_BYTES]
.scan:
    cmp rbx, r14
    jae .oom

    mov rax, [rbx]
    mov rcx, rax
    and rcx, -ALIGN
    test rax, FLAG_ALLOC
    jnz .next
    cmp rcx, r12
    jb .next

    mov rdx, rcx
    sub rdx, r12
    cmp rdx, MIN_BLOCK
    jb .nosplit

    mov rax, r12
    or rax, FLAG_ALLOC
    mov [rbx], rax
    lea r8, [rbx + r12 - FTR_BYTES]
    mov [r8], rax

    lea r9, [rbx + r12]
    mov r10, rdx
    and r10, -ALIGN
    mov [r9], r10
    lea r11, [r9 + r10 - FTR_BYTES]
    mov [r11], r10

    lea rax, [rbx + HDR_BYTES]
    leave
    ret

.nosplit:
    mov rax, rcx
    or rax, FLAG_ALLOC
    mov [rbx], rax
    lea r8, [rbx + rcx - FTR_BYTES]
    mov [r8], rax
    lea rax, [rbx + HDR_BYTES]
    leave
    ret

.next:
    add rbx, rcx
    jmp .scan

.oom:
    xor eax, eax
    leave
    ret

heap_free:
    test rdi, rdi
    jz .ret
    sub rdi, HDR_BYTES

    mov rax, [rdi]
    mov rcx, rax
    and rcx, -ALIGN
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

    ; coalesce next
    lea r9, [rdi + rcx]
    lea r10, [pool + POOL_BYTES]
    cmp r9, r10
    jae .prev
    mov rax, [r9]
    test rax, FLAG_ALLOC
    jnz .prev
    mov rdx, rax
    and rdx, -ALIGN
    add rcx, rdx
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

.prev:
    ; coalesce prev
    lea r11, [pool]
    cmp rdi, r11
    jbe .ret
    lea r12, [rdi - FTR_BYTES]
    mov rax, [r12]
    mov rdx, rax
    and rdx, -ALIGN
    test rax, FLAG_ALLOC
    jnz .ret
    sub rdi, rdx
    add rcx, rdx
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

.ret:
    ret

heap_stats:
    ; returns:
    ;   rax = total_free (sum of free block payload bytes)
    ;   rdx = largest_free (largest free block payload bytes)
    push rbp
    mov rbp, rsp
    sub rsp, 32

    xor rax, rax                 ; total_free
    xor rdx, rdx                 ; largest_free

    lea rbx, [pool]
    lea r14, [pool + POOL_BYTES]
.loop:
    cmp rbx, r14
    jae .done

    mov r8, [rbx]
    mov rcx, r8
    and rcx, -ALIGN              ; blk_size
    test r8, FLAG_ALLOC
    jnz .next

    ; free payload = blk_size - overhead
    mov r9, rcx
    sub r9, OVERHEAD
    add rax, r9
    cmp r9, rdx
    jbe .next
    mov rdx, r9

.next:
    add rbx, rcx
    jmp .loop

.done:
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 96

    call heap_init

    ; Allocate 16 blocks of 128 payload
    xor ebx, ebx
.alloc_loop:
    cmp ebx, 16
    jge .free_pattern
    mov edi, 128
    call heap_malloc
    mov [ptrs + rbx*8], rax
    inc ebx
    jmp .alloc_loop

.free_pattern:
    ; Free blocks 0,2,4,...,14 (creates holes)
    xor ebx, ebx
.free_loop:
    cmp ebx, 16
    jge .stats
    test bl, 1
    jnz .skip
    mov rdi, [ptrs + rbx*8]
    call heap_free
.skip:
    inc ebx
    jmp .free_loop

.stats:
    call heap_stats               ; rax=total, rdx=largest
    mov r12, rax
    mov r13, rdx

    lea rdi, [fmt_msg]
    lea rsi, [m1]
    xor eax, eax
    call printf

    ; ext_frag_pct = 100*(total-largest)/total  (if total != 0)
    xor r14, r14
    test r12, r12
    jz .print
    mov rax, r12
    sub rax, r13
    mov rbx, 100
    mul rbx                       ; rdx:rax = (total-largest)*100
    xor rdx, rdx                  ; keep it simple: values are small here
    div r12                       ; rax = pct
    mov r14, rax

.print:
    lea rdi, [fmt_stats]
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
