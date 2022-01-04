# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: BSD-3-Clause

CC  = gcc

# STREAM options:
# -DNTIMES control the number of times each stream kernel is executed
# -DOFFSET controls the number of bytes between each of the buffers
# -DSTREAM_TYPE specifies the data-type of elements in the buffers
# -DSTREAM_ARRAY_SIZE specifies the number of elements in each buffer
STREAM_CPP_OPTS   = -DNTIMES=100 -DOFFSET=0 -DSTREAM_TYPE=double
# Size per array is approx. ~2GB. Delibrately using non-power of 2 elements
# 256*1024*1024 elements = 268435456 elements = 2GiB with FP64
STREAM_ARRAY_SIZE = 269000000

ifdef size
STREAM_ARRAY_SIZE = $(size)
endif
STREAM_CPP_OPTS  += -DSTREAM_ARRAY_SIZE=$(STREAM_ARRAY_SIZE)

# gcc options to control the generated ISA
NEOVERSE_N1_COPTS      = -mcpu=neoverse-n1 -mtune=neoverse-n1
NEOVERSE_N2_COPTS      = -mcpu=neoverse-n2 -mtune=neoverse-n2
NEOVERSE_V1_COPTS      = -mcpu=neoverse-v1 -mtune=neoverse-v1
CORTEX_A53_COPTS       = -mcpu=cortex-a53 -mtune=cortex-a53
CORTEX_A72_COPTS       = -mcpu=cortex-a72 -mtune=cortex-a72
WESTMERE_COPTS         = -mcpu=westmere -mtune=westmere
HASWELL_COPTS          = -mcpu=haswell -mtune=haswell

# Common Intel Compiler options that are independent of ISA
COMMON_COPTS   = -Wall -Ofast -fopenmp -ftree-vectorize -fomit-frame-pointer -flto

NEOVERSE_N1_OBJS       = stream_neoverse_n1.o
NEOVERSE_N2_OBJS       = stream_neoverse_n2.o
NEOVERSE_V1_OBJS       = stream_neoverse_v1.o
CORTEX_A53_OBJS        = stream_cortex_a53.o
CORTEX_A72_OBJS        = stream_cortex_a72.o
WESTMERE_OBJS          = stream_westmere.o
HASWELL_OBJS           = stream_haswell.o

ifdef cpu
all: stream_$(cpu).bin
else
all: stream_neoverse_n1.bin stream_neoverse_n2.bin stream_neoverse_v1.bin stream_cortex_a53.bin stream_cortex_a72.bin
endif

SRC = stream.c

stream_neoverse_n1.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_N1_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_neoverse_n2.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_N2_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_neoverse_v1.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_V1_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_cortex_a53.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(CORTEX_A53_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_cortex_a72.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(CORTEX_A72_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_westmere.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(WESTMERE_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@
stream_haswell.o: $(SRC)
	$(CC) $(COMMON_COPTS) $(HASWELL_COPTS) $(STREAM_CPP_OPTS) -c $(SRC) -o $@


stream_neoverse_n1.bin: $(NEOVERSE_N1_OBJS)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_N1_COPTS) $^ -o $@
stream_neoverse_n2.bin: $(NEOVERSE_N2_OBJS)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_N2_COPTS) $^ -o $@
stream_neoverse_v1.bin: $(NEOVERSE_V1_OBJS)
	$(CC) $(COMMON_COPTS) $(NEOVERSE_V1_COPTS) $^ -o $@
stream_cortex_a53.bin: $(CORTEX_A53_OBJS)
	$(CC) $(COMMON_COPTS) $(CORTEX_A53_COPTS) $^ -o $@
stream_cortex_a72.bin: $(CORTEX_A72_OBJS)
	$(CC) $(COMMON_COPTS) $(CORTEX_A72_COPTS) $^ -o $@
stream_westmere.bin: $(WESTMERE_OBJS)
	$(CC) $(COMMON_COPTS) $(WESTMERE_COPTS) $^ -o $@
stream_haswell.bin: $(HASWELL_OBJS)
	$(CC) $(COMMON_COPTS) $(HASWELL_COPTS) $^ -o $@


help:
	@echo -e "Running 'make' with no options would compile the STREAM benchmark with $(STREAM_ARRAY_SIZE) FP64 elements per array for following Intel CPU's:\n"
	@echo -e "\tstream_avx.bin        => Targeted for Intel CPU's that support AVX ISA"
	@echo -e "\tstream_avx2.bin       => Targeted for Intel CPU's that support AVX2 ISA"
	@echo -e "\tstream_avx512.bin     => Targeted for Intel CPU's that support AVX512 ISA"
	@echo -e "\nThe following options are supported:"
	@echo -e "\tsize=<number_of_elements_per_array>"
	@echo ""
	@echo -e "\tcpu=<avx,avx2,avx512>"
	@echo ""
	@echo -e "\trfo=1 forces to use regular cached stores instead of non-temporal stores"
	@echo ""
	@echo -e "\nFew examples:"
	@echo -e "To compile STREAM benchmark only for Intel AVX512 CPU's, do:"
	@echo -e "\tmake cpu=avx512"
	@echo ""
	@echo -e "To compile STREAM benchmark for Intel AVX512 CPU's with each buffer containing 67108864 elements, do:"
	@echo -e "\tmake size=67108864 cpu=avx512"

clean:
	rm -rf *.o *.bin 

.PHONY: all clean help
