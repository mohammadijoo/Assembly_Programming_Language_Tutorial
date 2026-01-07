MODE ?= debug

ifeq ($(MODE),debug)
  NASMFLAGS := -f elf64 -g -F dwarf -I include/
  LDFLAGS   :=
else ifeq ($(MODE),release)
  NASMFLAGS := -f elf64 -O2 -I include/
  LDFLAGS   :=
else
  $(error Unknown MODE=$(MODE). Use MODE=debug or MODE=release)
endif
