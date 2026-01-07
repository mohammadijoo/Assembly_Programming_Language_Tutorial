# Makefile snippet for deterministic lib build
NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf
CC := gcc
CFLAGS := -O2 -g -Wall -Wextra

AR := ar
ARFLAGS := rcsD

BUILDDIR := build
LIB := $(BUILDDIR)/libasmutil.a

LIBOBJS := $(BUILDDIR)/add_u64.o $(BUILDDIR)/strlen_asm.o
TEST := $(BUILDDIR)/test_lib

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/add_u64.o: src/add_u64.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@

$(BUILDDIR)/strlen_asm.o: src/strlen_asm.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@

$(LIB): $(LIBOBJS)
	$(AR) $(ARFLAGS) $@ $^

$(BUILDDIR)/test_lib.o: src/test_lib.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TEST): $(BUILDDIR)/test_lib.o $(LIB)
	$(CC) -o $@ $^
