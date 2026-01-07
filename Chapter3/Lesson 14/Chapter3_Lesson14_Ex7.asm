; Chapter3_Lesson14_Ex7.asm
; Programming Exercise (Hard): UTF-8 "nth code point" pointer
;
; Task:
;   Implement utf8_nth_ptr(src, n) that returns a pointer to the first byte
;   of the n-th UTF-8 code point in a NUL-terminated buffer (0-based).
;   If the buffer is invalid UTF-8 or has fewer than (n+1) code points, return 0.
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex7.asm -o Chapter3_Lesson14_Ex7.o
;   ld Chapter3_Lesson14_Ex7.o -o Chapter3_Lesson14_Ex7

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title db "Exercise: utf8_nth_ptr (0-based indexing over code points)", 10, 0
  label_p   db "pointer offset(bytes) = ", 0
  nl        db 10, 0

  ; "A" + "é" + "B" : 41 C3 A9 42 00
  s db "A", 0xC3, 0xA9, "B", 0

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; request n=1 (the "é" code point)
  lea rdi, [s]
  mov esi, 1
  call utf8_nth_ptr
  test rax, rax
  jz .fail

  ; print (rax - base) as byte offset
  lea rbx, [s]
  sub rax, rbx
  lea rdi, [label_p]
  call print_cstr
  mov rdi, rax
  call print_u64_dec
  call print_nl
  jmp .exit

.fail:
  lea rdi, [label_p]
  call print_cstr
  mov rdi, 0
  call print_u64_dec
  call print_nl

.exit:
  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; utf8_nth_ptr
; in :
;   rdi = src cstr
;   esi = n (0-based)
; out:
;   rax = pointer to nth code point, or 0 on error/out-of-range
; --------------------------------------------
utf8_nth_ptr:
  xor edx, edx                  ; byte index
  xor ecx, ecx                  ; code point index

.loop:
  mov al, [rdi+rdx]
  test al, al
  je .out_of_range

  cmp ecx, esi
  je .found

  ; validate and get sequence length in EAX
  lea r8, [rdi+rdx]             ; current pointer
  mov rdi, r8
  call utf8_seqlen_checked_ptr  ; CF=1 invalid, EAX=len
  jc .invalid

  add edx, eax
  inc ecx
  jmp .loop

.found:
  lea rax, [rdi+rdx]
  ret

.invalid:
.out_of_range:
  xor eax, eax
  ret

; --------------------------------------------
; utf8_seqlen_checked_ptr
; in : rdi = pointer to lead byte
; out: CF=0 and EAX=1..4 if valid; CF=1 otherwise
; --------------------------------------------
utf8_seqlen_checked_ptr:
  mov bl, [rdi]
  cmp bl, 0x80
  jb .one

  mov al, bl
  and al, 0xE0
  cmp al, 0xC0
  je .two

  mov al, bl
  and al, 0xF0
  cmp al, 0xE0
  je .three

  mov al, bl
  and al, 0xF8
  cmp al, 0xF0
  je .four

  stc
  ret

.one:
  mov eax, 1
  clc
  ret

.two:
  cmp bl, 0xC2
  jb .bad
  mov bh, [rdi+1]
  call is_cont_bh
  jc .bad
  mov eax, 2
  clc
  ret

.three:
  mov bh, [rdi+1]
  call is_cont_bh
  jc .bad
  mov bh, [rdi+2]
  call is_cont_bh
  jc .bad

  cmp bl, 0xE0
  jne .check_sur
  cmp byte [rdi+1], 0xA0
  jb .bad

.check_sur:
  cmp bl, 0xED
  jne .ok3
  cmp byte [rdi+1], 0xA0
  jae .bad

.ok3:
  mov eax, 3
  clc
  ret

.four:
  cmp bl, 0xF4
  ja .bad
  mov bh, [rdi+1]
  call is_cont_bh
  jc .bad
  mov bh, [rdi+2]
  call is_cont_bh
  jc .bad
  mov bh, [rdi+3]
  call is_cont_bh
  jc .bad

  cmp bl, 0xF0
  jne .check_max
  cmp byte [rdi+1], 0x90
  jb .bad

.check_max:
  cmp bl, 0xF4
  jne .ok4
  cmp byte [rdi+1], 0x8F
  ja .bad

.ok4:
  mov eax, 4
  clc
  ret

.bad:
  stc
  ret

; is_cont_bh: CF=1 if BH is not a continuation byte, else CF=0
is_cont_bh:
  mov al, bh
  and al, 0xC0
  cmp al, 0x80
  jne .no
  clc
  ret
.no:
  stc
  ret

; --------------------------------------------
; printing helpers
; --------------------------------------------
strlen_loop:
  xor eax, eax
.loop2:
  cmp byte [rdi+rax], 0
  je .done2
  inc rax
  jmp .loop2
.done2:
  ret

print_cstr:
  push rdi
  call strlen_loop
  mov rdx, rax
  pop rsi
  mov eax, SYS_write
  mov edi, STDOUT
  syscall
  ret

print_nl:
  lea rdi, [nl]
  jmp print_cstr

print_u64_dec:
  lea rsi, [decbuf+31]
  mov byte [rsi], 0
  mov rax, rdi
  test rax, rax
  jne .conv
  mov byte [rsi-1], '0'
  lea rdi, [rsi-1]
  jmp print_cstr
.conv:
  mov rcx, 10
.loop3:
  xor rdx, rdx
  div rcx
  add dl, '0'
  dec rsi
  mov [rsi], dl
  test rax, rax
  jne .loop3
  mov rdi, rsi
  call print_cstr
  ret
