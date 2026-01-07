; decode_len(ptr in RDI) -> RAX = length or 0
; This is a learning skeleton; a production decoder needs many more cases.

global decode_len
section .text

decode_len:
  xor eax, eax
  mov rsi, rdi           ; cursor

  ; Optional REX prefix: 0x40..0x4F
  mov bl, [rsi]
  and bl, 0xF0
  cmp bl, 0x40
  jne .no_rex
  inc rsi
.no_rex:

  mov bl, [rsi]          ; opcode
  inc rsi

  ; Case 1: jcc rel8 (0x70..0x7F)
  cmp bl, 0x70
  jb  .not_jcc
  cmp bl, 0x7F
  ja  .not_jcc
  ; length = (rsi - rdi) + 1 byte displacement
  inc rsi
  jmp .finish

.not_jcc:
  ; Case 2: mov r64, imm (B8..BF)
  cmp bl, 0xB8
  jb  .maybe_modrm
  cmp bl, 0xBF
  ja  .maybe_modrm
  ; In x86-64, operand size depends on REX.W. For simplicity:
  ; treat as imm32 (sign-extended) unless you enforce REX.W handling.
  add rsi, 4
  jmp .finish

.maybe_modrm:
  ; For our subset: MOV r/m64,r64 (0x89) and MOV r64,r/m64 (0x8B)
  ; ADD r/m64, imm8 (0x83 /0) and imm32 (0x81 /0)
  cmp bl, 0x89
  je  .need_modrm
  cmp bl, 0x8B
  je  .need_modrm
  cmp bl, 0x83
  je  .need_modrm_add_imm8
  cmp bl, 0x81
  je  .need_modrm_add_imm32
  xor eax, eax
  ret

.need_modrm:
  ; parse ModRM and optional SIB/disp
  call .parse_modrm
  test eax, eax
  jz .bad
  jmp .finish

.need_modrm_add_imm8:
  call .parse_modrm
  test eax, eax
  jz .bad
  add rsi, 1            ; imm8
  jmp .finish

.need_modrm_add_imm32:
  call .parse_modrm
  test eax, eax
  jz .bad
  add rsi, 4            ; imm32
  jmp .finish

.bad:
  xor eax, eax
  ret

.finish:
  mov rax, rsi
  sub rax, rdi
  ret

; Helper: parse ModRM at [rsi], advance rsi accordingly; return EAX=1 success, 0 fail
.parse_modrm:
  mov dl, [rsi]
  inc rsi

  ; mod = bits 7..6, rm = bits 2..0
  mov al, dl
  shr al, 6             ; AL = mod
  and dl, 7             ; DL = rm

  ; If mod != 3 and rm == 4 => SIB present
  cmp al, 3
  je  .no_mem
  cmp dl, 4
  jne .no_sib
  ; parse SIB
  mov dh, [rsi]
  inc rsi
  ; base = bits 2..0
  and dh, 7
  ; special case: mod=0 and base=5 => disp32
  cmp al, 0
  jne .sib_done
  cmp dh, 5
  jne .sib_done
  add rsi, 4
.sib_done:
  jmp .disp_by_mod

.no_sib:
  ; special case: mod=0 and rm=5 => disp32 (RIP-relative)
  cmp al, 0
  jne .disp_by_mod
  cmp dl, 5
  jne .disp_by_mod
  add rsi, 4
  mov eax, 1
  ret

.disp_by_mod:
  cmp al, 1
  jne .mod2
  add rsi, 1
  mov eax, 1
  ret
.mod2:
  cmp al, 2
  jne .ok
  add rsi, 4
.ok:
  mov eax, 1
  ret

.no_mem:
  mov eax, 1
  ret
