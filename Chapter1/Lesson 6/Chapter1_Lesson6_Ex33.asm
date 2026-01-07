# Add to Makefile
ENV_CHECK = tools/env_check.sh

$(TARGET): $(ENV_CHECK) $(OBJS)
	./$(ENV_CHECK)
	$(LD) -o $@ $(OBJS)
