AR := ar
ARFLAGS := rcsD   # "D" requests deterministic mode on many binutils ar variants

LIB := build/libasmutil.a
OBJS := build/print_nasm.o build/add_u64.o

$(LIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
