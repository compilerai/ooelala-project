LLVM_PATH = /opt/llvm
CLANG = $(LLVM_PATH)/build/bin/clang
CLANG-UNSEQ = $(LLVM_PATH)/build/bin/clang -Xclang -load -Xclang $(LLVM_PATH)/build/lib/UnsequencedAliasVisitor.so -Xclang -add-plugin -Xclang unseq
GCC = gcc 
ICC = icc 

%-test: %-build %-run %-clean
	echo "Test$(patsubst %-test, %, $@) completed"

%-build:
	$(eval test=$(patsubst %-build, %, $@))
	echo "Building $(test)"
	time -f "clang : %U" $(CLANG) -Ofast $(test)/*.c -o $(test)-clang 
	time -f "gcc : %U" $(GCC) -Ofast $(test)/*.c -o $(test)-gcc 
	time -f "icc : %U" $(ICC) -Ofast $(test)/*.c -o $(test)-icc 
	time -f "unseq : %U" $(CLANG-UNSEQ) -Ofast $(test)/*.c -o $(test)-unseq 

%-run:
	$(eval test=$(patsubst %-run, %, $@))
	echo "Running $(test)"
	time -f "clang : %U" ./$(test)-clang
	time -f "gcc : %U" ./$(test)-gcc
	time -f "icc : %U" ./$(test)-icc
	time -f "unseq : %U" ./$(test)-unseq

%-clean:
	$(eval test=$(patsubst %-clean, %, $@))
	rm -f $(test)-clang $(test)-gcc $(test)-icc $(test)-unseq

clean:
	rm -f *-clang *-gcc *-icc *-unseq
