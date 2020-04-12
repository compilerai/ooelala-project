CC = /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

SPEC_FLAGS = -DSPEC -DNDEBUG -DSPEC_AUTO_BYTEORDER=0x12345678 -DHAVE_CONFIG_H=1 -DSPEC_MEM_IO -DSPEC_XZ -DSPEC_AUTO_SUPPRESS_OPENMP -DSPEC_LP64 -Wno-everything
OPT_FLAGS = -O3 -mavx

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

INCLUDES = -I. -Ispec_mem_io -Isha-2 -Icommon -Iliblzma/api -Iliblzma/lzma -Iliblzma/common -Iliblzma/check -Iliblzma/simple -Iliblzma/delta -Iliblzma/lz -Iliblzma/rangecoder
SOURCES = spec.c spec_xz.c pxz.c common/tuklib_physmem.c liblzma/common/common.c liblzma/common/block_util.c liblzma/common/easy_preset.c liblzma/common/filter_common.c liblzma/common/hardware_physmem.c liblzma/common/index.c liblzma/common/stream_flags_common.c liblzma/common/vli_size.c liblzma/common/alone_encoder.c liblzma/common/block_buffer_encoder.c liblzma/common/block_encoder.c liblzma/common/block_header_encoder.c liblzma/common/easy_buffer_encoder.c liblzma/common/easy_encoder.c liblzma/common/easy_encoder_memusage.c liblzma/common/filter_buffer_encoder.c liblzma/common/filter_encoder.c liblzma/common/filter_flags_encoder.c liblzma/common/index_encoder.c liblzma/common/stream_buffer_encoder.c liblzma/common/stream_encoder.c liblzma/common/stream_flags_encoder.c liblzma/common/vli_encoder.c liblzma/common/alone_decoder.c liblzma/common/auto_decoder.c liblzma/common/block_buffer_decoder.c liblzma/common/block_decoder.c liblzma/common/block_header_decoder.c liblzma/common/easy_decoder_memusage.c liblzma/common/filter_buffer_decoder.c liblzma/common/filter_decoder.c liblzma/common/filter_flags_decoder.c liblzma/common/index_decoder.c liblzma/common/index_hash.c liblzma/common/stream_buffer_decoder.c liblzma/common/stream_decoder.c liblzma/common/stream_flags_decoder.c liblzma/common/vli_decoder.c liblzma/check/check.c liblzma/check/crc32_table.c liblzma/check/crc32_fast.c liblzma/check/crc64_table.c liblzma/check/crc64_fast.c liblzma/check/sha256.c liblzma/lz/lz_encoder.c liblzma/lz/lz_encoder_mf.c liblzma/lz/lz_decoder.c liblzma/lzma/lzma_encoder.c liblzma/lzma/lzma_encoder_presets.c liblzma/lzma/lzma_encoder_optimum_fast.c liblzma/lzma/lzma_encoder_optimum_normal.c liblzma/lzma/fastpos_table.c liblzma/lzma/lzma_decoder.c liblzma/lzma/lzma2_encoder.c liblzma/lzma/lzma2_decoder.c liblzma/rangecoder/price_table.c liblzma/delta/delta_common.c liblzma/delta/delta_encoder.c liblzma/delta/delta_decoder.c liblzma/simple/simple_coder.c liblzma/simple/simple_encoder.c liblzma/simple/simple_decoder.c liblzma/simple/x86.c liblzma/simple/powerpc.c liblzma/simple/ia64.c liblzma/simple/arm.c liblzma/simple/armthumb.c liblzma/simple/sparc.c xz/args.c xz/coder.c xz/file_io.c xz/hardware.c xz/list.c xz/main.c xz/message.c xz/options.c xz/signals.c xz/util.c common/tuklib_open_stdxxx.c common/tuklib_progname.c common/tuklib_exit.c common/tuklib_cpucores.c common/tuklib_mbstr_width.c common/tuklib_mbstr_fw.c spec_mem_io/spec_mem_io.c sha-2/sha512.c
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
UNSEQ_OBJECTS = $(patsubst %.c, %-unseq.o, $(SOURCES))

xz: $(OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS) -lm -o xz

unseq: $(UNSEQ_OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS) -lm -o xz-unseq

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
	rm -f xz xz-unseq
	rm -f $(OBJECTS) $(UNSEQ_OBJECTS)
