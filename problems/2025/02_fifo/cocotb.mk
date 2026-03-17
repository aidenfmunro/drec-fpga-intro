SIM ?= icarus
TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)
VERILOG_SOURCES += $(PWD)/src/sync_fifo.v $(PWD)/tb/sync_fifo_stub.v

TOPLEVEL = sync_fifo_stub

MODULE = sync_fifo_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
