CC = /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

SPEC_FLAGS = -DSPEC -DNDEBUG -DSPEC_AUTO_SUPPRESS_OPENMP -DSPEC_AUTO_BYTEORDER=0x12345678 -DSPEC_LP64 -Wno-everything
OPT_FLAGS = -O3 -mavx

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

INCLUDES = -Ildecod_src/inc -Ix264_src -Ix264_src/extras -Ix264_src/common 
SOURCES_x264 = x264_src/common/mc.c x264_src/common/predict.c x264_src/common/pixel.c x264_src/common/macroblock.c x264_src/common/frame.c x264_src/common/dct.c x264_src/common/cpu.c x264_src/common/cabac.c x264_src/common/common.c x264_src/common/mdate.c x264_src/common/rectangle.c x264_src/common/set.c x264_src/common/quant.c x264_src/common/deblock.c x264_src/common/vlc.c x264_src/common/mvpred.c x264_src/encoder/analyse.c x264_src/encoder/me.c x264_src/encoder/ratecontrol.c x264_src/encoder/set.c x264_src/encoder/macroblock.c x264_src/encoder/cabac.c x264_src/encoder/cavlc.c x264_src/encoder/encoder.c x264_src/encoder/lookahead.c x264_src/input/timecode.c x264_src/input/yuv.c x264_src/input/y4m.c x264_src/output/raw.c x264_src/output/matroska.c x264_src/output/matroska_ebml.c x264_src/output/flv.c x264_src/output/flv_bytestream.c x264_src/input/thread.c x264_src/x264.c x264_src/extras/getopt.c
OBJECTS_x264 = $(patsubst %.c, %.o, $(SOURCES_x264))
UNSEQ_OBJECTS_x264 = $(patsubst %.c, %-unseq.o, $(SOURCES_x264))

SOURCES_LDECODE = ldecod_src/nal.c ldecod_src/mbuffer_mvc.c ldecod_src/image.c ldecod_src/mb_access.c ldecod_src/memalloc.c ldecod_src/mc_prediction.c ldecod_src/mb_prediction.c ldecod_src/intra4x4_pred_mbaff.c ldecod_src/loop_filter_mbaff.c ldecod_src/context_ini.c ldecod_src/configfile.c ldecod_src/cabac.c ldecod_src/sei.c ldecod_src/leaky_bucket.c ldecod_src/filehandle.c ldecod_src/errorconcealment.c ldecod_src/decoder_test.c ldecod_src/img_process.c ldecod_src/mv_prediction.c ldecod_src/fmo.c ldecod_src/output.c ldecod_src/mc_direct.c ldecod_src/rtp.c ldecod_src/nalucommon.c ldecod_src/config_common.c ldecod_src/intra_chroma_pred.c ldecod_src/transform8x8.c ldecod_src/blk_prediction.c ldecod_src/intra8x8_pred_mbaff.c ldecod_src/erc_do_i.c ldecod_src/io_tiff.c ldecod_src/mbuffer.c ldecod_src/block.c ldecod_src/intra4x4_pred.c ldecod_src/transform.c ldecod_src/annexb.c ldecod_src/ldecod.c ldecod_src/macroblock.c ldecod_src/vlc.c ldecod_src/parset.c ldecod_src/loop_filter_normal.c ldecod_src/parsetcommon.c ldecod_src/erc_do_p.c ldecod_src/loopFilter.c ldecod_src/intra16x16_pred_mbaff.c ldecod_src/intra4x4_pred_normal.c ldecod_src/intra16x16_pred_normal.c ldecod_src/win32.c ldecod_src/intra16x16_pred.c ldecod_src/intra8x8_pred_normal.c ldecod_src/io_raw.c ldecod_src/img_io.c ldecod_src/nalu.c ldecod_src/quant.c ldecod_src/intra8x8_pred.c ldecod_src/erc_api.c ldecod_src/header.c ldecod_src/biaridecod.c ldecod_src/input.c
OBJECTS_LDECODE = $(patsubst %.c, %.o, $(SOURCES_LDECODE))
UNSEQ_OBJECTS_LDECODE = $(patsubst %.c, %-unseq.o, $(SOURCES_LDECODE))

x264: $(OBJECTS_x264)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS_x264) -lm -o x264

unseq: $(UNSEQ_OBJECTS_x264)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS_x264) -lm -o x264-unseq

ldecod: $(OBJECTS_LDECODE)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS_LDECODE) -lm -o ldecod

ldecod-unseq: $(UNSEQ_OBJECTS_LDECODE)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS_LDECODE) -lm -o ldecod-unseq

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
	rm -f x264 ldecod x264-unseq ldecod-unseq
	rm -f $(OBJECTS) $(UNSEQ_OBJECTS)
