CC = /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

SPEC_FLAGS = -DSPEC -DNDEBUG -DNOPERFLIB -DNOREDUCE -DSPEC_AUTO_SUPPRESS_OPENMP -DSPEC_LP64 -Wno-everything
OPT_FLAGS = -O3 -mavx

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

INCLUDES = -Ispecrand -Iregex-alpha
SOURCES = nabmd.c sff.c nblist.c prm.c memutil.c molio.c molutil.c errormsg.c binpos.c rand2.c select_atoms.c reslib.c database.c traceback.c chirvol.c specrand/specrand.c regex-alpha/regcomp.c regex-alpha/regerror.c regex-alpha/regexec.c regex-alpha/regfree.c
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
UNSEQ_OBJECTS = $(patsubst %.c, %-unseq.o, $(SOURCES))

nab: $(OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS) -lm -o nab

unseq: $(UNSEQ_OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS) -lm -o nab-unseq

%.o: %.c
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $< -m64 -c -o $@

%-unseq.o: %.c
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $(UNSEQ_FLAGS) $< -m64 -c -o $@

%.ll: %.c
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $(LL_FLAGS) $< -m64 -c -o $@

%-unseq.ll: %.c
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $(UNSEQ_FLAGS) $(LL_FLAGS) $< -m64 -c -o $@
	# sed -i '/unseq\.noalias/d' $@

%.stats: %.c
	$(eval obj=$(basename $<))
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $(STAT_FLAGS) $< -m64 -c -o $(obj).o

%-unseq.stats: %.c
	$(eval obj=$(basename $<))
	$(CC) $(INCLUDES) $(SPEC_FLAGS) $(OPT_FLAGS) $(UNSEQ_FLAGS) $(STAT_FLAGS) $< -m64 -c -o $(obj)-unseq.o

clean::
	rm -f nab nab-unseq
	rm -f $(OBJECTS) $(UNSEQ_OBJECTS)
