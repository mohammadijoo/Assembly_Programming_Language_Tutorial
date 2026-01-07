; Chapter3_Lesson14_Ex6.asm
; Topic: UTF-8 practicalities — validate and count code points vs bytes
; Build (Linux x86-64):
;   nasm -felf64 Chapter3_Lesson14_Ex6.asm -o Chapter3_Lesson14_Ex6.o
;   ld Chapter3_Lesson14_Ex6.o -o Chapter3_Lesson14_Ex6

BITS 64
DEFAULT REL
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

SECTION .data
  msg_title db "UTF-8: bytes vs code points; validator with basic overlong checks", 10, 0
  label_1   db "ascii string: bytes=", 0
  label_2   db "utf8  string: bytes=", 0
  label_3   db "invalid utf8: bytes=", 0
  label_cp  db " codepoints=", 0
  label_ok  db " ok(1/0)=", 0
  nl        db 10, 0

  ; ASCII: each code point is exactly 1 byte
  s_ascii db "Cafe", 0

  ; UTF-8: "Caf" + U+00E9 (é) encoded as C3 A9
  s_utf8  db "Caf", 0xC3, 0xA9, 0

  ; Invalid: starts with a continuation byte (10xxxxxx) without a lead byte
  s_bad   db 0x80, "X", 0

SECTION .bss
  decbuf resb 32

SECTION .text
_start:
  lea rdi, [msg_title]
  call print_cstr

  ; Example 1
  lea rdi, [label_1]
  call print_cstr
  lea rdi, [s_ascii]
  call utf8_validate_count_cstr     ; rax=codepoints, rdx=bytes, r8b=ok
  mov rdi, rdx
  call print_u64_dec
  lea rdi, [label_cp]
  call print_cstr
  mov rdi, rax
  call print_u64_dec
  lea rdi, [label_ok]
  call print_cstr
  movzx rdi, r8b
  call print_u64_dec
  call print_nl

  ; Example 2
  lea rdi, [label_2]
  call print_cstr
  lea rdi, [s_utf8]
  call utf8_validate_count_cstr
  mov rdi, rdx
  call print_u64_dec
  lea rdi, [label_cp]
  call print_cstr
  mov rdi, rax
  call print_u64_dec
  lea rdi, [label_ok]
  call print_cstr
  movzx rdi, r8b
  call print_u64_dec
  call print_nl

  ; Example 3
  lea rdi, [label_3]
  call print_cstr
  lea rdi, [s_bad]
  call utf8_validate_count_cstr
  mov rdi, rdx
  call print_u64_dec
  lea rdi, [label_cp]
  call print_cstr
  mov rdi, rax
  call print_u64_dec
  lea rdi, [label_ok]
  call print_cstr
  movzx rdi, r8b
  call print_u64_dec
  call print_nl

  mov eax, SYS_exit
  xor edi, edi
  syscall

; --------------------------------------------
; utf8_validate_count_cstr
; Validates a NUL-terminated byte sequence under a practical subset of UTF-8 rules:
; - recognizes 1..4 byte sequences based on leading byte pattern
; - checks continuation bytes have 10xxxxxx pattern
; - rejects overlong encodings with common leading-byte constraints
; - rejects code points above U+10FFFF via leading byte constraint (lead <= F4)
; - rejects surrogate range U+D800..U+DFFF via ED A0..ED BF constraint
;
; in :
;   rdi = pointer to NUL-terminated bytes
; out:
;   rax = number of code points
;   rdx = number of bytes (excluding the terminator 0)
;   r8b = 1 if valid, 0 if invalid
; --------------------------------------------
utf8_validate_count_cstr:
  xor eax, eax         ; codepoint count
  xor edx, edx         ; byte count
  mov r8b, 1           ; ok
.loop:
  mov bl, [rdi+rdx]
  test bl, bl
  je .done

  cmp bl, 0x80
  jb .one_byte

  ; 2-byte lead: 110xxxxx, but must be >= C2 to avoid overlong encodings
  mov bh, bl
  and bh, 0xE0
  cmp bh, 0xC0
  je .two_byte

  ; 3-byte lead: 1110xxxx
  mov bh, bl
  and bh, 0xF0
  cmp bh, 0xE0
  je .three_byte

  ; 4-byte lead: 11110xxx, must be <= F4
  mov bh, bl
  and bh, 0xF8
  cmp bh, 0xF0
  je .four_byte

  jmp .invalid

.one_byte:
  inc eax
  inc edx
  jmp .loop

.two_byte:
  cmp bl, 0xC2
  jb .invalid
  mov bh, [rdi+rdx+1]
  call is_cont
  jc .invalid
  inc eax
  add edx, 2
  jmp .loop

.three_byte:
  mov bh, [rdi+rdx+1]
  call is_cont
  jc .invalid
  mov cl, [rdi+rdx+2]
  mov bh, cl
  call is_cont
  jc .invalid

  ; Overlong: E0 A0..BF is the minimal 3-byte range
  cmp bl, 0xE0
  jne .check_surrogate
  cmp byte [rdi+rdx+1], 0xA0
  jb .invalid

.check_surrogate:
  ; Surrogates: ED A0..BF xx are invalid
  cmp bl, 0xED
  jne .three_ok
  cmp byte [rdi+rdx+1], 0xA0
  jae .invalid

.three_ok:
  inc eax
  add edx, 3
  jmp .loop

.four_byte:
  cmp bl, 0xF4
  ja .invalid
  mov bh, [rdi+rdx+1]
  call is_cont
  jc .invalid
  mov cl, [rdi+rdx+2]
  mov bh, cl
  call is_cont
  jc .invalid
  mov cl, [rdi+rdx+3]
  mov bh, cl
  call is_cont
  jc .invalid

  ; Overlong: F0 90..BF .. is the minimal 4-byte range
  cmp bl, 0xF0
  jne .check_max
  cmp byte [rdi+rdx+1], 0x90
  jb .invalid

.check_max:
  ; Max U+10FFFF: F4 80..8F .. is the maximal lead-2 range
  cmp bl, 0xF4
  jne .four_ok
  cmp byte [rdi+rdx+1], 0x8F
  ja .invalid

.four_ok:
  inc eax
  add edx, 4
  jmp .loop

.invalid:
  mov r8b, 0
.done:
  ret

; is_cont: CF=1 if BH is not a continuation byte, else CF=0
; Continuation must satisfy (b & C0) == 80
is_cont:
  mov al, bh
  and al, 0xC0
  cmp al, 0x80
  jne .bad
  clc
  ret
.bad:
  stc
  ret

; --------------------------------------------
; printing helpers (strlen_loop)
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
