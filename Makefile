STD=--std=02
OPTS=--ieee=synopsys
#RUN_OPTS=--vcd=dump.vcd --stop-time=2ms
RUN_OPTS=

#TOP=test_sampling
TOP=test_activation
SOURCE=\
			 sampling_pkg.vhdl \
			 lfsr.vhdl \
			 test_lfsr.vhdl \
			 input_sum.vhdl \
			 activation.vhdl \
			 sampler.vhdl \
			 sampling_network.vhdl \
			 test_sampling.vhdl \
			 test_activation.vhdl

all: run

activation: elaborate_activation
	./test_activation

sampling: elaborate_sampling
	#./test_sampling --vcd=dump.vcd --stop-time=10ms
	./test_sampling --stop-time=2ms

.PHONY: clean
clean:
	ghdl --clean

analyze: $(SOURCE)
	ghdl -a $(STD) $(OPTS) $(SOURCE)

elaborate_sampling: analyze
	ghdl -e $(OPTS) test_sampling 

elaborate_activation: analyze
	ghdl -e $(OPTS) test_activation

