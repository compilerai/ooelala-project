COMP ?= /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

INCLUDES = -I common/
OPT_FLAGS = -O3
POLYBFLAGS ?= -Wno-unknown-pragmas -DPOLYBENCH_TIME

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

%: %.c
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $< -lm -o $@

%-unseq: %.c
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $(UNSEQ_FLAGS) $< -lm -o $@

%.ll: %.c
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $(LL_FLAGS) $< -o $@

%-unseq.ll: %.c
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $(UNSEQ_FLAGS) $(LL_FLAGS) $< -o $@

%.stats: %.c 
	$(eval exec=$(basename $<))
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $(STAT_FLAGS) $< -lm -o $(exec) 

%-unseq.stats: %.c
	$(eval exec=$(basename $<))
	$(COMP) $(POLYBFLAGS) $(INCLUDES) $(OPT_FLAGS) $(UNSEQ_FLAGS) $(STAT_FLAGS) $< -lm -o $(exec)-unseq
	mv $(notdir $(exec)).stats $(notdir $(exec))-unseq.stats

%-clean: %.c
	$(eval exec=$(basename $<))
	rm -f $(exec) $(exec).ll $(exec).stats

%-unseq-clean: %.c
	$(eval exec=$(basename $<))
	rm -f $(exec)-unseq $(exec)-unseq.ll $(exec)-unseq.stats

%-polly:
	$(MAKE) $(patsubst %-polly, %, $@)
