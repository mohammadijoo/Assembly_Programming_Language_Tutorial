; Chapter 7 - Lesson 4 - Exercise Solution 4
; Boundary-tag allocator over an mmap'd 8 KiB arena with:
;   - header/footer: size|alloc_bit (LSB)
;   - explicit singly-linked free list (next pointer stored at blk+8 when free)
;   - splitting + coalescing (prev/next via boundary tags)
; Educational, not production-hardened.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex10.asm -o ex10.o
;   gcc -no-pie ex10.o -o ex10

default rel

global main
extern mmap
extern munmap
extern printf
extern exit

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

%define ARENA_SZ    8192
%define ALLOC_BIT   1
%define MIN_FREE    32          ; hdr+ftr+next (8+8+8) rounded to 32

section .data
fmt_a   db "alloc(%ld) -> %p", 10, 0
fmt_f   db "free(%p)", 10, 0
fmt_d   db "block @%p size=%ld alloc=%ld", 10, 0
msg_bad db "allocator init failed", 10, 0

section .bss
arena_base  resq 1
free_head   resq 1

section .text

; align16(x): rdi -> rax
align16:
    lea  rax, [rdi + 15]
    and  rax, -16
    ret

; set header/footer: blk=rdi, size=rsi, alloc_flag=rdx(0/1)
set_hdr_ftr:
    mov  rax, rsi
    test rdx, rdx
    jz   .noa
    or   rax, ALLOC_BIT
.noa:
    mov  [rdi], rax
    lea  rcx, [rdi + rsi - 8]
    mov  [rcx], rax
    ret

; get block size: blk=rdi -> rax=size (alloc bit stripped)
blk_size:
    mov  rax, [rdi]
    and  rax, -2
    ret

; is_alloc: blk=rdi -> rax=0/1
is_alloc:
    mov  rax, [rdi]
    and  rax, ALLOC_BIT
    ret

; free list push: rdi=blk
fl_push:
    mov  rax, [free_head]
    mov  [rdi + 8], rax
    mov  [free_head], rdi
    ret

; free list remove: rdi=target
fl_remove:
    mov  rax, [free_head]
    test rax, rax
    jz   .done
    cmp  rax, rdi
    jne  .scan

    mov  rdx, [rax + 8]
    mov  [free_head], rdx
    jmp  .done

.scan:
    mov  rcx, rax                 ; prev
    mov  rax, [rax + 8]           ; cur
    test rax, rax
    jz   .done
    cmp  rax, rdi
    jne  .next

    mov  rdx, [rax + 8]
    mov  [rcx + 8], rdx
    jmp  .done

.next:
    mov  rcx, rax
    mov  rax, [rax + 8]
    jmp  .scan

.done:
    ret

; init: mmap arena and create one big free block
; returns eax=0 ok, eax=1 fail
bt_init:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    xor  edi, edi
    mov  esi, ARENA_SZ
    mov  edx, PROT_READ | PROT_WRITE
    mov  ecx, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9d, r9d
    call mmap
    cmp  rax, -1
    je   .fail

    mov  [arena_base], rax
    mov  [free_head], rax

    mov  rdi, rax
    mov  rsi, ARENA_SZ
    xor  edx, edx
    call set_hdr_ftr
    mov  qword [rdi + 8], 0        ; next = NULL

    xor  eax, eax
    leave
    ret

.fail:
    mov  eax, 1
    leave
    ret


; --- To keep the file compact and correct, implement malloc/free inline in main as routines with saved total. ---

; void* bt_malloc(size_t n)
; rdi=n -> rax=user_ptr or 0
bt_malloc:
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    mov  [rbp-8], rdi              ; n
    mov  rdi, [rbp-8]
    add  rdi, 16
    call align16
    mov  [rbp-16], rax             ; total

    mov  r11, [rbp-16]             ; total in r11
    mov  r10, [free_head]          ; cur

.search:
    test r10, r10
    jz   .fail

    mov  rdi, r10
    call blk_size
    cmp  rax, r11
    jae  .found

    mov  r10, [r10 + 8]
    jmp  .search

.found:
    ; remove from free list
    mov  rdi, r10
    call fl_remove

    ; old_size = size(cur)
    mov  rdi, r10
    call blk_size
    mov  [rbp-24], rax             ; old_size

    ; remaining = old_size - total
    mov  rax, [rbp-24]
    sub  rax, r11
    mov  [rbp-32], rax             ; remaining

    cmp  rax, MIN_FREE
    jb   .nosplit

    ; split: allocated block at cur with size=total
    mov  rdi, r10
    mov  rsi, r11
    mov  edx, 1
    call set_hdr_ftr

    ; remainder block at cur+total with size=remaining
    lea  rdi, [r10 + r11]
    mov  rsi, [rbp-32]
    xor  edx, edx
    call set_hdr_ftr
    mov  qword [rdi + 8], 0
    call fl_push                  ; push remainder

    lea  rax, [r10 + 8]           ; user ptr (after header)
    leave
    ret

.nosplit:
    ; allocate whole block (mark alloc bit)
    mov  rdi, r10
    mov  rsi, [rbp-24]
    mov  edx, 1
    call set_hdr_ftr
    lea  rax, [r10 + 8]
    leave
    ret

.fail:
    xor  eax, eax
    leave
    ret

\
; void bt_free(void* p)
; rdi=user_ptr
bt_free:
    test rdi, rdi
    jz   .z
    sub  rdi, 8                    ; blk = p-8
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    mov  [rbp-8], rdi              ; blk

    ; mark free
    mov  rdi, [rbp-8]
    call blk_size
    mov  [rbp-16], rax             ; size

    mov  rdi, [rbp-8]
    mov  rsi, [rbp-16]
    xor  edx, edx
    call set_hdr_ftr

    ; coalesce with next if free and in arena
    mov  r10, [rbp-8]              ; blk
    mov  r11, [rbp-16]             ; size
    lea  r8,  [r10 + r11]          ; next

    mov  rax, [arena_base]
    lea  rdx, [rax + ARENA_SZ]
    cmp  r8, rdx
    jae  .co_prev                  ; next out of bounds

    mov  rdi, r8
    call is_alloc
    test rax, rax
    jnz  .co_prev                  ; next allocated

    ; remove next from free list, merge
    mov  rdi, r8
    call fl_remove
    mov  rdi, r8
    call blk_size

    mov  r11, [rbp-16]
    add  r11, rax                  ; size += next_size
    mov  [rbp-16], r11

    mov  rdi, [rbp-8]
    mov  rsi, [rbp-16]
    xor  edx, edx
    call set_hdr_ftr

.co_prev:
    ; coalesce with prev if free and in arena
    mov  r10, [rbp-8]              ; blk
    mov  rax, [arena_base]
    cmp  r10, rax
    jbe  .push                     ; at base, no prev

    ; prev_size from footer at blk-8
    mov  r9,  [r10 - 8]
    and  r9,  -2                   ; prev_size
    lea  r8,  [r10 - r9]           ; prev_blk

    cmp  r8, rax
    jb   .push

    mov  rdi, r8
    call is_alloc
    test rax, rax
    jnz  .push

    ; remove prev from free list, merge into prev
    mov  rdi, r8
    call fl_remove

    mov  r11, [rbp-16]
    add  r11, r9                   ; size += prev_size
    mov  [rbp-16], r11
    mov  [rbp-8], r8               ; blk = prev_blk

    mov  rdi, [rbp-8]
    mov  rsi, [rbp-16]
    xor  edx, edx
    call set_hdr_ftr

.push:
    mov  rdi, [rbp-8]
    mov  qword [rdi + 8], 0
    call fl_push

    leave
.z:
    ret
\
; dump blocks
bt_dump:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    mov  r10, [arena_base]
    lea  r11, [r10 + ARENA_SZ]
.loop:
    cmp  r10, r11
    jae  .done

    mov  [rbp-8], r10              ; save iterator across printf

    mov  rdi, r10
    call blk_size
    mov  r8, rax

    mov  rdi, r10
    call is_alloc
    mov  r9, rax

    lea  rdi, [fmt_d]
    mov  rsi, [rbp-8]
    mov  rdx, r8
    mov  rcx, r9
    xor  eax, eax
    call printf

    mov  r10, [rbp-8]
    add  r10, r8
    jmp  .loop
.done:
    leave
    ret


main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 96

    call bt_init
    test eax, eax
    jnz  .bad

    ; p1 = malloc(100)
    mov  edi, 100
    call bt_malloc
    mov  [rbp-8], rax
    lea  rdi, [fmt_a]
    mov  rsi, 100
    mov  rdx, rax
    xor  eax, eax
    call printf

    ; p2 = malloc(200)
    mov  edi, 200
    call bt_malloc
    mov  [rbp-16], rax
    lea  rdi, [fmt_a]
    mov  rsi, 200
    mov  rdx, rax
    xor  eax, eax
    call printf

    ; p3 = malloc(50)
    mov  edi, 50
    call bt_malloc
    mov  [rbp-24], rax
    lea  rdi, [fmt_a]
    mov  rsi, 50
    mov  rdx, rax
    xor  eax, eax
    call printf

    call bt_dump

    ; free p2
    lea  rdi, [fmt_f]
    mov  rsi, [rbp-16]
    xor  eax, eax
    call printf

    mov  rdi, [rbp-16]
    call bt_free

    call bt_dump

    ; allocate 180 (should fit into freed space with split)
    mov  edi, 180
    call bt_malloc
    mov  [rbp-32], rax
    lea  rdi, [fmt_a]
    mov  rsi, 180
    mov  rdx, rax
    xor  eax, eax
    call printf

    call bt_dump

    ; cleanup: munmap
    mov  rdi, [arena_base]
    mov  esi, ARENA_SZ
    call munmap

    xor  eax, eax
    leave
    ret

.bad:
    lea  rdi, [msg_bad]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit
