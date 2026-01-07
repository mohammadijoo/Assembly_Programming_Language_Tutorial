; Chapter3_Lesson14_Ex8.asm
; Programming Exercise (Very Hard): UTF-8 substring by code points (safe byte-copy)
;
; Task:
;   Implement utf8_substr_copy(src, start_cp, count_cp, dst, dst_cap)
;   that copies exactly count_cp code points starting at start_cp into dst,
;   without cutting a multi-byte sequence. Always NUL-terminate if dst_cap>0.
;   Return bytes written (excluding terminator). On invalid UTF-8 or out-of-range,
;   return 0 and write an empty string (if possible).
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex8.asm -o Chapter3_Lesson14_Ex8.o
;   ld Chapter3_Lesson14_Ex8.o -o Chapter3_Lesson14_Ex8

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title db "Exercise: utf8_substr_copy (by code points, NUL-terminated)", 10, 0
  label_out db "substring = ", 0
  nl        db 10, 0

  ; "Hi " + "世界" (CJK) in UTF-8:
  ; 世 U+4E16: E4 B8 96
  ; 界 U+754C: E7 95 8C
  s db "Hi ", 0xE4,0xB8,0x96, 0xE7,0x95,0x8C, "!", 0

SECTION .bss
  outbuf resb 16
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; Copy 2 code points starting at start_cp=3 (世, 界)
  lea rdi, [s]         ; src
  mov esi, 3           ; start_cp
  mov edx, 2           ; count_cp
  lea rcx, [outbuf]    ; dst
  mov r8d, 16          ; dst_cap
  call utf8_substr_copy

  ; print result
  lea rdi, [label_out]
  call print_cstr
  lea rdi, [outbuf]
  call print_cstr
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; utf8_substr_copy
; in :
;   rdi = src cstr
;   esi = start_cp
;   edx = count_cp
;   rcx = dst buffer
;   r8d = dst_cap
; out:
;   rax = bytes written (excluding terminator), or 0 on error/out-of-range
; --------------------------------------------
utf8_substr_copy:
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi             ; src base
  mov r13, rcx             ; dst base
  mov r14d, r8d            ; dst cap
  mov r15d, edx            ; count_cp

  ; if dst_cap==0, nothing we can do
  test r14d, r14d
  jz .fail_zero

  ; default: empty output
  mov byte [r13], 0

  ; Find pointer to start_cp
  mov rdi, r12
  call utf8_nth_ptr_local   ; uses ESI as n; returns RAX ptr or 0
  test rax, rax
  jz .fail_zero

  mov r10, rax              ; src_ptr
  xor edx, edx              ; bytes_written
  xor r11d, r11d            ; copied_cp

.loop:
  cmp r11d, r15d
  je .done_ok

  mov bl, [r10]
  test bl, bl
  je .fail_zero             ; hit terminator early

  mov rdi, r10
  call utf8_seqlen_checked_ptr
  jc .fail_zero
  mov ebx, eax              ; len in bytes

  ; remaining payload capacity = (dst_cap-1) - bytes_written
  mov ecx, r14d
  dec ecx
  sub ecx, edx
  cmp ecx, ebx
  jb .done_truncated

  ; Copy EBX bytes
  lea rdi, [r13+rdx]
  mov rsi, r10
  mov ecx, ebx
  cld
  rep movsb
  mov r10, rsi              ; advanced src_ptr

  add edx, ebx              ; bytes_written += len
  inc r11d                  ; copied_cp++
  jmp .loop

.done_truncated:
  mov byte [r13+rdx], 0
  mov eax, edx
  jmp .ret

.done_ok:
  mov byte [r13+rdx], 0
  mov eax, edx
  jmp .ret

.fail_zero:
  xor eax, eax
  test r14d, r14d
  jz .ret
  mov byte [r13], 0

.ret:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  ret

; --------------------------------------------
; utf8_nth_ptr_local
; in : rdi = src cstr, esi = n
; out: rax = pointer or 0
; --------------------------------------------
utf8_nth_ptr_local:
  xor edx, edx                  ; byte index
  xor ecx, ecx                  ; code point index
.loop_n:
  mov al, [rdi+rdx]
  test al, al
  je .oor
  cmp ecx, esi
  je .found
  lea r8, [rdi+rdx]
  mov rdi, r8
  call utf8_seqlen_checked_ptr
  jc .oor
  add edx, eax
  inc ecx
  jmp .loop_n
.found:
  lea rax, [rdi+rdx]
  ret
.oor:
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
