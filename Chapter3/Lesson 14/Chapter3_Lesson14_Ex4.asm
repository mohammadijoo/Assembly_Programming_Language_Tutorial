; Chapter3_Lesson14_Ex4.asm
; Topic: strcmp (NUL-terminated) and memcmp-style compare (length-prefixed) using CMPSB
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex4.asm -o Chapter3_Lesson14_Ex4.o
;   ld Chapter3_Lesson14_Ex4.o -o Chapter3_Lesson14_Ex4

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title  db "string comparisons: strcmp loop and repe cmpsb", 10, 0
  label_s1   db "strcmp('kitten','sitting') = ", 0
  label_s2   db "pstrcmp16('ab','ab')       = ", 0
  label_s3   db "pstrcmp16('ab','aba')      = ", 0
  nl         db 10, 0
  minus      db "-"

  a_c db "kitten", 0
  b_c db "sitting", 0

  ; pstr16: [u16 len][payload]
  p_ab  dw 2
        db "a", "b"
  p_ab2 dw 2
        db "a", "b"
  p_aba dw 3
        db "a", "b", "a"

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; strcmp example
  lea rdi, [label_s1]
  call print_cstr
  lea rdi, [a_c]
  lea rsi, [b_c]
  call strcmp_cstr
  movsxd rdi, eax
  call print_i64_dec
  call print_nl

  ; pstrcmp16 equal
  lea rdi, [label_s2]
  call print_cstr
  lea rdi, [p_ab]
  lea rsi, [p_ab2]
  call pstrcmp16
  movsxd rdi, eax
  call print_i64_dec
  call print_nl

  ; pstrcmp16 shorter vs longer
  lea rdi, [label_s3]
  call print_cstr
  lea rdi, [p_ab]
  lea rsi, [p_aba]
  call pstrcmp16
  movsxd rdi, eax
  call print_i64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; strcmp_cstr: lexicographic compare for NUL-terminated strings
; in : rdi=a, rsi=b
; out: eax = -1, 0, +1
; --------------------------------------------
strcmp_cstr:
.loop:
  mov al, [rdi]
  mov dl, [rsi]
  cmp al, dl
  jne .diff
  test al, al
  je .eq
  inc rdi
  inc rsi
  jmp .loop
.diff:
  ja .gt
  mov eax, -1
  ret
.gt:
  mov eax, 1
  ret
.eq:
  xor eax, eax
  ret

; --------------------------------------------
; pstrcmp16: compare [u16 len][bytes...] with explicit length
; Uses REPE CMPSB to compare min(lenA,lenB) bytes.
; in : rdi=a_pstr16, rsi=b_pstr16
; out: eax = -1,0,+1
; --------------------------------------------
pstrcmp16:
  push rbx
  push r12

  movzx ebx, word [rdi]           ; lenA
  movzx r12d, word [rsi]          ; lenB
  lea rdi, [rdi+2]                ; a payload
  lea rsi, [rsi+2]                ; b payload

  ; rcx = min(lenA, lenB)
  mov ecx, ebx
  cmp ecx, r12d
  jbe .min_ok
  mov ecx, r12d
.min_ok:
  cld
  repe cmpsb                      ; compares byte [RSI] with byte [RDI]

  jne .mismatch

  ; All min bytes equal; compare lengths
  cmp ebx, r12d
  je .eq2
  jb .shorter
  mov eax, 1
  jmp .done
.shorter:
  mov eax, -1
  jmp .done
.eq2:
  xor eax, eax
  jmp .done

.mismatch:
  ; RSI and RDI have advanced one past the mismatching position.
  mov al, [rsi-1]
  mov dl, [rdi-1]
  cmp al, dl
  ja .gt2
  mov eax, -1
  jmp .done
.gt2:
  mov eax, 1

.done:
  pop r12
  pop rbx
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

; print signed integer in RDI
print_i64_dec:
  mov rax, rdi
  test rax, rax
  jns .pos
  ; print '-'
  push rdi
  mov edi, STDOUT
  lea rsi, [minus]
  mov edx, 1
  mov eax, SYS_write
  syscall
  pop rdi
  neg rdi
.pos:
  jmp print_u64_dec

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
