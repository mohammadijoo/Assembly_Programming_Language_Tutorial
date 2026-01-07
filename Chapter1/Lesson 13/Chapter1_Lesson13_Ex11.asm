APP := build/app_nasm

.PHONY: run disasm symbols

run: $(APP)
	./$(APP)

disasm: $(APP)
	objdump -d -Mintel $(APP) | less

symbols: $(APP)
	nm -n $(APP) | less
