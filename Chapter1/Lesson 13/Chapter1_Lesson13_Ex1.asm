asm-workflow-demo/
  CMakeLists.txt
  Makefile
  include/
    syscalls_linux_x86_64.inc
    print_macros.inc
  src/
    main_nasm.asm
    print_nasm.asm
    main_gas.S
    print_gas.S
  scripts/
    build.sh
    clean.sh
  build/              # generated; safe to delete
    (objects, deps, binaries)
