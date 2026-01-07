; abi_adapter.inc
%ifndef ABI_ADAPTER_INC
%define ABI_ADAPTER_INC 1

; Choose exactly one ABI by defining ABI_SYSV or ABI_WIN64 before including.
%ifdef ABI_SYSV
  %define ARG0 rdi
  %define ARG1 rsi
%elifdef ABI_WIN64
  %define ARG0 rcx
  %define ARG1 rdx
%else
  %error "Define ABI_SYSV or ABI_WIN64 before including abi_adapter.inc"
%endif

%macro DEF_LEAF 1
  global %1
  %1:
%endmacro

%endif