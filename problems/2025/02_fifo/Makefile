TARGET = tb.vvp

CC   = iverilog
SIM  = vvp
VIEW = gtkwave

SRC_DIR = src
TB_DIR  = tb
TB_TOP_NAME  = sync_fifo_dummy_tb

SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
TB_FILE = $(TB_DIR)/$(TB_TOP_NAME).v


compile: $(TB_FILE) $(SRC_FILES)
	$(CC) -o $(TARGET) $^

run: $(TARGET)
	$(SIM) $<

view:
	$(VIEW) dump.vcd

info:
	@echo $(SRC_FILES)

clean:
	rm *.vcd *.vvp

.PHONY: compile run view info clean
