CC = /opt/llvm/build/bin/clang
UNSEQ_PLUGIN = /opt/llvm/build/lib/UnsequencedAliasVisitor.so

SPEC_FLAGS = -DSPEC -DNDEBUG -DSPEC_AUTO_SUPPRESS_OPENMP -DSPEC_LP64 -Wno-everything
OPT_FLAGS = -O3 -mavx

LL_FLAGS = -S -emit-llvm
STAT_FLAGS = -mllvm -enable-aa-eval -save-stats
UNSEQ_FLAGS = -Xclang -load -Xclang $(UNSEQ_PLUGIN) -Xclang -add-plugin -Xclang unseq

INCLUDES = -I. 
SOURCES = coders/tga.c filters/analyze.c magick/accelerate.c magick/animate.c magick/annotate.c magick/artifact.c magick/attribute.c magick/blob.c magick/cache-view.c magick/cache.c magick/channel.c magick/cipher.c magick/client.c magick/coder.c magick/color.c magick/colormap.c magick/colorspace.c magick/compare.c magick/composite.c magick/compress.c magick/configure.c magick/constitute.c magick/decorate.c magick/delegate.c magick/display.c magick/distort.c magick/distribute-cache.c magick/draw.c magick/effect.c magick/enhance.c magick/exception.c magick/feature.c magick/fourier.c magick/fx.c magick/gem.c magick/geometry.c magick/hashmap.c magick/histogram.c magick/identify.c magick/image.c magick/layer.c magick/list.c magick/locale.c magick/log.c magick/magic.c magick/magick.c magick/matrix.c magick/memory.c magick/mime.c magick/module.c magick/monitor.c magick/montage.c magick/morphology.c magick/option.c magick/paint.c magick/pixel.c magick/policy.c magick/prepress.c magick/profile.c magick/property.c magick/quantize.c magick/quantum-export.c magick/quantum-import.c magick/quantum.c magick/random.c magick/registry.c magick/resample.c magick/resize.c magick/resource.c magick/segment.c magick/semaphore.c magick/shear.c magick/signature.c magick/splay-tree.c magick/static.c magick/statistic.c magick/stream.c magick/string.c magick/threshold.c magick/timer.c magick/token.c magick/transform.c magick/type.c magick/utility.c magick/version.c magick/xml-tree.c utilities/convert.c wand/convert.c wand/drawing-wand.c wand/magick-image.c wand/magick-wand.c wand/mogrify.c wand/pixel-wand.c wand/magick-property.c wand/pixel-iterator.c wand/wand.c magick/deprecate.c
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
UNSEQ_OBJECTS = $(patsubst %.c, %-unseq.o, $(SOURCES))

imagick: $(OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(OBJECTS) -lm -o imagick

unseq: $(UNSEQ_OBJECTS)
	$(CC) -m64 -z muldefs $(OPT_FLAGS) -z muldefs $(UNSEQ_OBJECTS) -lm -o imagick-unseq

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
	rm -f imagick imagick-unseq
	rm -f $(OBJECTS) $(UNSEQ_OBJECTS)
