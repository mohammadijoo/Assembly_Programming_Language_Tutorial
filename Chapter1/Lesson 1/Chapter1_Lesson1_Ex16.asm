; Conceptual example: calling an external symbol (details later in the course)
section .text
global my_add
extern puts

my_add:
  ; ... compute something ...
  ret