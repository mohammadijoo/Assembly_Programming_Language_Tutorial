; Chapter3_Lesson14_Ex10.asm
; Programming Exercise (Hard): Boyer-Moore-Horspool substring search on NUL-terminated strings
;
; Task:
;   Implement bmh_find(text, pattern) that returns the 0-based byte index of the first match
;   of pattern in text, or -1 if no match.
;
; Notes:
;   - This is a byte-oriented search (not code points). For UTF-8, it finds byte sequences.
;   - We compute text_len and pat_len first to avoid reading beyond the NUL terminator.
;   - Shift table is 256 bytes.
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex10.asm -o Chapter3_Lesson14_Ex10.o
;   ld Chapter3_Lesson14_Ex10.o -o Chapter3_Lesson14_Ex10

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title db "Exercise: Boyer-Moore-Horspool on cstr (byte index result)", 10, 0
  label_r   db "index = ", 0
  nl        db 10, 0

  text db "A needle in a haystack. Another needle.", 0
  pat  db "needle", 0

SECTION .bss
  shift resb 256
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  lea rdi, [text]
  lea rsi, [pat]
  call bmh_find
  ; print result (signed)
  lea rdi, [label_r]
  call print_cstr
  movsxd rdi, eax
  call print_i64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; strlen_loop
; in : rdi=cstr
; out: rax=len
; --------------------------------------------
strlen_loop:
  xor eax, eax
.loop0:
  cmp byte [rdi+rax], 0
  je .done0
  inc rax
  jmp .loop0
.done0:
  ret

; --------------------------------------------
; bmh_find(text, pattern)
; in : rdi=text cstr, rsi=pattern cstr
; out: eax = index (0..), or -1 if not found
; --------------------------------------------
bmh_find:
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi             ; text base
  mov r13, rsi             ; pat base

  ; pat_len
  mov rdi, r13
  call strlen_loop
  mov r14d, eax            ; pat_len
  test r14d, r14d
  jnz .pat_nonempty
  xor eax, eax             ; empty pattern matches at 0
  jmp .ret

.pat_nonempty:
  ; text_len
  mov rdi, r12
  call strlen_loop
  mov r15d, eax            ; text_len

  ; if pat_len > text_len -> not found
  cmp r14d, r15d
  jbe .build_shift
  mov eax, -1
  jmp .ret

.build_shift:
  ; shift[c] = pat_len for all c
  mov ecx, 256
  mov al, r14b
  lea rdi, [shift]
  cld
  rep stosb

  ; for i=0..pat_len-2: shift[pat[i]] = pat_len-1-i
  xor ebx, ebx             ; i
  mov edx, r14d
  dec edx                  ; pat_len-1
  jz .search               ; pat_len == 1: table stays default
.fill_loop:
  mov al, [r13+rbx]
  mov ecx, r14d
  dec ecx
  sub ecx, ebx
  mov [shift+rax], cl
  inc ebx
  cmp ebx, edx
  jb .fill_loop

.search:
  xor ebx, ebx             ; pos = 0
  mov edx, r15d
  sub edx, r14d            ; last_start = text_len - pat_len

.outer:
  cmp ebx, edx
  ja .not_found

  ; compare from end j = pat_len-1 down to 0
  mov ecx, r14d
  dec ecx                  ; j = pat_len-1

.inner:
  mov al, [r13+rcx]        ; pat[j]
  mov dl, [r12+rbx+rcx]    ; text[pos+j]
  cmp al, dl
  jne .mismatch
  test ecx, ecx
  je .found
  dec ecx
  jmp .inner

.mismatch:
  ; shift by shift[text[pos+pat_len-1]]
  movzx eax, byte [r12+rbx+r14-1]
  movzx eax, byte [shift+rax]
  add ebx, eax
  jmp .outer

.found:
  mov eax, ebx
  jmp .ret

.not_found:
  mov eax, -1

.ret:
  pop r15
  pop r14
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

; print signed integer in RDI
print_i64_dec:
  mov rax, rdi
  test rax, rax
  jns .pos
  ; print '-'
  push rdi
  mov edi, STDOUT
  lea rsi, [rel minus]
  mov edx, 1
  mov eax, SYS_write
  syscall
  pop rdi
  neg rdi
.pos:
  jmp print_u64_dec

minus db "-"

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
