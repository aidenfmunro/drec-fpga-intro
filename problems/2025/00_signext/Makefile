TARGET = tb.vvp

CC   = iverilog
SIM  = vvp
VIEW = gtkwave

SRC_DIR = src
TB_DIR  = tb
TB_TOP_NAME  = sign_ext_tb

SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
TB_FILE = $(TB_DIR)/$(TB_TOP_NAME).v


compile: $(TB_FILE) $(SRC_FILES)
	$(CC) -o $(TARGET) $^

run: $(TARGET)
	$(SIM) $<

info:
	@echo $(SRC_FILES)

clean:
	rm *.vcd *.vvp


