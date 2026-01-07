; Chapter3_Lesson14_Ex9.asm
; Programming Exercise (Very Hard): Constant-time equality compare with padded length-prefixed strings
;
; Motivation:
;   A truly constant-time compare for variable-length strings is subtle because time can leak length
;   and you must avoid reading past valid memory. A practical engineering pattern is to store secrets
;   in fixed-size slots, padded to a maximum. The prefix holds the logical length, but the storage is fixed.
;
; Representation used here:
;   struct slot {
;     u8  len;
;     u8  data[MAX];    ; data beyond len is padded with 0
;   }
; Compare is constant-time in MAX (loops exactly MAX iterations).
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex9.asm -o Chapter3_Lesson14_Ex9.o
;   ld Chapter3_Lesson14_Ex9.o -o Chapter3_Lesson14_Ex9

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%define MAX 32

SECTION .data
  msg_title db "Exercise: constant-time slot equality (fixed MAX loop)", 10, 0
  label_eq  db "eq(1/0) = ", 0
  nl        db 10, 0

  ; slot1: len=8, "password", padded to MAX with zeros
  slot1 db 8
        db "password"
        times (MAX-8) db 0

  ; slot2: len=8, "password"
  slot2 db 8
        db "password"
        times (MAX-8) db 0

  ; slot3: len=8, "passw0rd" (one byte differs)
  slot3 db 8
        db "passw0rd"
        times (MAX-8) db 0

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; Compare slot1 vs slot2 (expect 1)
  lea rdi, [slot1]
  lea rsi, [slot2]
  call slot_eq_ct
  lea rdi, [label_eq]
  call print_cstr
  movzx rdi, al
  call print_u64_dec
  call print_nl

  ; Compare slot1 vs slot3 (expect 0)
  lea rdi, [slot1]
  lea rsi, [slot3]
  call slot_eq_ct
  lea rdi, [label_eq]
  call print_cstr
  movzx rdi, al
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; slot_eq_ct
; in :
;   rdi = slot A (len byte + MAX data bytes)
;   rsi = slot B
; out:
;   AL = 1 if equal (len and all MAX bytes equal), else 0
; Constant-time in MAX (always loops MAX times).
; --------------------------------------------
slot_eq_ct:
  push rcx
  push rbx

  mov al, [rdi]          ; lenA
  xor al, [rsi]          ; diff starts with len mismatch
  mov bl, al             ; accumulator in BL

  lea rdi, [rdi+1]       ; point at data
  lea rsi, [rsi+1]

  mov ecx, MAX
.loop:
  mov al, [rdi]
  xor al, [rsi]
  or bl, al
  inc rdi
  inc rsi
  dec ecx
  jnz .loop

  ; If BL==0 then equal
  cmp bl, 0
  sete al

  pop rbx
  pop rcx
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
