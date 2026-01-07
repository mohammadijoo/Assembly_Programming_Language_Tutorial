; Example: a function that uses RBX (callee-saved) must preserve it (SysV-style)
global my_func
my_func:
  push rbx                 ; preserve callee-saved
  ; ... do work using rbx ...
  pop  rbx                 ; restore
  ret
