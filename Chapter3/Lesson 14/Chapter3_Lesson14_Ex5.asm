; Chapter3_Lesson14_Ex5.asm
; Topic: Bounded copy/concatenation patterns for NUL-terminated strings (strlcpy/strlcat style)
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex5.asm -o Chapter3_Lesson14_Ex5.o
;   ld Chapter3_Lesson14_Ex5.o -o Chapter3_Lesson14_Ex5

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title db "bounded string ops: strlcpy/strlcat-style", 10, 0
  label_a   db "dst after strlcpy = ", 0
  label_b   db "dst after strlcat = ", 0
  label_r1  db "strlcpy returned  = ", 0
  label_r2  db "strlcat returned  = ", 0
  nl        db 10, 0

  src1 db "short", 0
  src2 db " + a much longer suffix that will not fit", 0

SECTION .bss
  dst    resb 24
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; rax = strlcpy(dst, src1, 24) returns src length (attempted)
  lea rdi, [dst]
  lea rsi, [src1]
  mov edx, 24
  call strlcpy_cstr
  mov rbx, rax

  lea rdi, [label_a]
  call print_cstr
  lea rdi, [dst]
  call print_cstr
  call print_nl

  lea rdi, [label_r1]
  call print_cstr
  mov rdi, rbx
  call print_u64_dec
  call print_nl

  ; rax = strlcat(dst, src2, 24) returns dst_len + src_len (attempted)
  lea rdi, [dst]
  lea rsi, [src2]
  mov edx, 24
  call strlcat_cstr
  mov rbx, rax

  lea rdi, [label_b]
  call print_cstr
  lea rdi, [dst]
  call print_cstr
  call print_nl

  lea rdi, [label_r2]
  call print_cstr
  mov rdi, rbx
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; strlen_loop
; in : rdi = cstr
; out: rax = length
; --------------------------------------------
strlen_loop:
  xor eax, eax
.loop:
  cmp byte [rdi+rax], 0
  je .done
  inc rax
  jmp .loop
.done:
  ret

; --------------------------------------------
; strlcpy_cstr
; Copies src to dst with truncation, always NUL-terminates if cap>0.
; in :
;   rdi = dst
;   rsi = src
;   edx = cap (bytes)
; out:
;   rax = strlen(src) (attempted length)
; --------------------------------------------
strlcpy_cstr:
  push rbx
  push r12
  mov r12d, edx            ; cap
  mov rbx, rdi             ; dst base
  mov r11, rsi             ; src base

  ; src_len -> RAX
  mov rdi, r11
  call strlen_loop
  mov r10, rax             ; src_len saved

  ; if cap == 0: return src_len, do not write
  test r12d, r12d
  jz .ret

  ; payload bytes we can copy: min(src_len, cap-1)
  mov ecx, r12d
  dec ecx
  mov rdx, r10
  cmp rdx, rcx
  jbe .copy_ok
  mov rdx, rcx
.copy_ok:
  ; copy RDX bytes
  mov rdi, rbx             ; dst
  mov rsi, r11             ; src
  mov rcx, rdx
  cld
  rep movsb
  mov byte [rdi], 0

.ret:
  mov rax, r10
  pop r12
  pop rbx
  ret

; --------------------------------------------
; strlcat_cstr
; Appends src to dst with truncation; always NUL-terminates if cap>0 and dst is NUL-terminated within cap.
; in :
;   rdi = dst
;   rsi = src
;   edx = cap
; out:
;   rax = initial_dst_len + src_len (attempted total length) OR cap + src_len if dst not terminated within cap
; --------------------------------------------
strlcat_cstr:
  push rbx
  push r12
  push r13
  mov r12, rdi             ; dst base
  mov r13, rsi             ; src base
  mov r11d, edx            ; cap

  ; find dst length defensively within cap
  xor ebx, ebx             ; dst_len
.find_dst:
  cmp ebx, r11d
  jae .dst_not_terminated
  cmp byte [r12+rbx], 0
  je .dst_len_found
  inc ebx
  jmp .find_dst

.dst_not_terminated:
  ; attempted = cap + src_len, no write
  mov rdi, r13
  call strlen_loop
  lea eax, [r11d+eax]
  jmp .ret

.dst_len_found:
  ; src_len
  mov rdi, r13
  call strlen_loop
  mov edx, eax             ; src_len

  ; attempted = dst_len + src_len
  lea eax, [ebx+edx]
  mov r10d, eax            ; attempted saved

  ; if dst_len >= cap: cannot append (shouldn't happen if terminated, but defensive)
  cmp ebx, r11d
  jae .ret_attempted

  ; payload_capacity = cap - dst_len - 1
  mov ecx, r11d
  sub ecx, ebx
  dec ecx
  jle .ret_attempted

  ; copy_len = min(src_len, payload_capacity)
  cmp edx, ecx
  jbe .copy_len_ok
  mov edx, ecx
.copy_len_ok:
  ; copy EDX bytes
  lea rdi, [r12+rbx]       ; dst + dst_len
  mov rsi, r13
  mov ecx, edx
  cld
  rep movsb
  mov byte [rdi], 0

.ret_attempted:
  mov eax, r10d
.ret:
  pop r13
  pop r12
  pop rbx
  ret

; --------------------------------------------
; printing helpers
; --------------------------------------------
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
.loop2:
  xor rdx, rdx
  div rcx
  add dl, '0'
  dec rsi
  mov [rsi], dl
  test rax, rax
  jne .loop2
  mov rdi, rsi
  call print_cstr
  ret
