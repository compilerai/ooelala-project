CC = /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

SPEC_FLAGS = -DSPEC -DNDEBUG -DPERL_CORE -DDOUBLE_SLASHES_SPECIAL=0 -DSPEC_AUTO_SUPPRESS_OPENMP -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -DSPEC_LINUX_X64 -DSPEC_LP64 -Wno-everything
OPT_FLAGS = -O3 -mavx

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

INCLUDES = -I. -Idist/IO -Icpan/Time-HiRes -Icpan/HTML-Parser -Iext/re -Ispecrand 
SOURCES = av.c caretx.c deb.c doio.c doop.c dump.c globals.c gv.c hv.c keywords.c locale.c mg.c numeric.c op.c pad.c perl.c perlapi.c perlio.c perlmain.c perly.c pp.c pp_ctl.c pp_hot.c pp_pack.c pp_sort.c pp_sys.c regcomp.c regexec.c run.c scope.c sv.c taint.c toke.c universal.c utf8.c util.c reentr.c mro_core.c mathoms.c specrand/specrand.c dist/PathTools/Cwd.c dist/Data-Dumper/Dumper.c ext/Devel-Peek/Peek.c cpan/Digest-MD5/MD5.c cpan/Digest-SHA/SHA.c DynaLoader.c dist/IO/IO.c dist/IO/poll.c cpan/MIME-Base64/Base64.c Opcode.c dist/Storable/Storable.c ext/Sys-Hostname/Hostname.c cpan/Time-HiRes/HiRes.c ext/XS-Typemap/stdio.c ext/attributes/attributes.c cpan/HTML-Parser/Parser.c ext/mro/mro.c ext/re/re.c ext/re/re_comp.c ext/re/re_exec.c ext/arybase/arybase.c ext/PerlIO-scalar/scalar.c ext/PerlIO-via/via.c ext/File-Glob/bsd_glob.c ext/File-Glob/Glob.c ext/Hash-Util/Util.c ext/Hash-Util-FieldHash/FieldHash.c ext/Tie-Hash-NamedCapture/NamedCapture.c cpan/Scalar-List-Utils/ListUtil.c
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
UNSEQ_OBJECTS = $(patsubst %.c, %-unseq.o, $(SOURCES))

perlbench: $(OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS) -lm -o perlbench

unseq: $(UNSEQ_OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS) -lm -o perlbench-unseq

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
	rm -f perlbench perlbench-unseq
	rm -f $(OBJECTS) $(UNSEQ_OBJECTS)
