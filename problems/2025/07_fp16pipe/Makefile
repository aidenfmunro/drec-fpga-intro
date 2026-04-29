TEST_SIZE ?= 4096
TEST_OP   ?= add
DEBUG     ?= 0
PIPE 	  ?= 0

TB_LIST := fp16u_tb.v

RTL_LIST := fp16add_pipe0.v fp16add_pipe1.v fp16add_pipe2.v fp16add_pipe3.v fp16add_pipe4.v fp16add_pipe5.v

sim: $(TB_LIST) $(RTL_LIST)
	python3 test.py $(TEST_SIZE) $(TEST_OP) > test.txt
	iverilog -g2012 $^ -o sim -DTEST_SIZE=$(TEST_SIZE) -DTEST_OP=$(TEST_OP) -DDEBUG=$(DEBUG) -DPIPE=$(PIPE)
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd test.txt

.PHONY: clean sim waves
