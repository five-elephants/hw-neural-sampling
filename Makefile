STD=--std=02
OPTS=--ieee=synopsys
RUN_OPTS=--vcd=dump.vcd --stop-time=100us

TOP=test_sampling
SOURCE=\
			 sampling_pkg.vhdl \
			 lfsr.vhdl \
			 test_lfsr.vhdl \
			 sampler.vhdl \
			 sampling_network.vhdl \
			 test_sampling.vhdl

all: run

.PHONY: clean
clean:
	ghdl --clean

analyze: $(SOURCE)
	ghdl -a $(STD) $(OPTS) $(SOURCE)

elaborate: analyze
	ghdl -e $(OPTS) $(TOP)

run: elaborate
	./$(TOP) $(RUN_OPTS)

