TARGET = tb.vvp

CC   = iverilog
SIM  = vvp
VIEW = gtkwave

SRC_DIR = src
TB_DIR  = tb
TB_TOP_NAME  = lsfr_tb

SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
TB_FILE = $(TB_DIR)/$(TB_TOP_NAME).v


compile: $(TB_FILE) $(SRC_FILES)
	$(CC) -o $(TARGET) $^

run: $(TARGET)
	$(SIM) $<

info:
	@echo $(SRC_FILES)

view:
	$(VIEW) dump.vcd

clean:
	rm *.vcd *.vvp

.PHONY: compile run info clean
