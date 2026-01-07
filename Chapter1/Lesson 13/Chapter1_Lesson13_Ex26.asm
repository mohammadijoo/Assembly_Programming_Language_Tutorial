# Makefile — reference solution for Exercise 1
MODE ?= debug

SRCDIR := src
INCDIR := include
BUILDDIR := build

NASM := nasm
LD   := ld
CC   := gcc

ifeq ($(MODE),debug)
  NASMFLAGS := -f elf64 -g -F dwarf -I $(INCDIR)/
  CFLAGS := -O0 -g -Wall -Wextra
else ifeq ($(MODE),release)
  NASMFLAGS := -f elf64 -O2 -I $(INCDIR)/
  CFLAGS := -O2 -Wall -Wextra
else
  $(error Unknown MODE=$(MODE))
endif

# --- NASM syscall-only app ---
NASM_APP := $(BUILDDIR)/app_nasm
NASM_SOURCES := main_nasm.asm print_nasm.asm
NASM_OBJS := $(NASM_SOURCES:%.asm=$(BUILDDIR)/%.o)
NASM_DEPS := $(NASM_SOURCES:%.asm=$(BUILDDIR)/%.d)

# --- Mixed C + ASM app ---
MIX_APP := $(BUILDDIR)/mix_app
MIX_OBJS := $(BUILDDIR)/main.o $(BUILDDIR)/add_u64.o

.PHONY: all clean run disasm symbols
all: $(NASM_APP) $(MIX_APP)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Include auto-generated deps if present
-include $(NASM_DEPS)

# NASM compile rule + dep generation
$(BUILDDIR)/%.o: $(SRCDIR)/%.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@
	$(NASM) -M -I $(INCDIR)/ $< > $(BUILDDIR)/$*.d

$(NASM_APP): $(NASM_OBJS)
	$(LD) -o $@ $^

# C compile
$(BUILDDIR)/main.o: $(SRCDIR)/main.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Assembly function for mixed target
$(BUILDDIR)/add_u64.o: $(SRCDIR)/add_u64.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@

$(MIX_APP): $(MIX_OBJS)
	$(CC) -o $@ $^

run: $(NASM_APP) $(MIX_APP)
	./$(NASM_APP)
	./$(MIX_APP)

disasm: $(NASM_APP)
	objdump -d -Mintel $(NASM_APP) | less

symbols: $(NASM_APP)
	nm -n $(NASM_APP) | less

clean:
	rm -rf $(BUILDDIR)
