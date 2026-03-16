import logging
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from queue import Queue
import random

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

class TB:
    def __init__(self, dut):
        self.dut = dut
        self.queue = Queue()

        self.dut.i_wr_en.value   = 0
        self.dut.i_wr_data.value = 0
        self.dut.i_rd_en.value   = 0
        self.dut.rst_n.value     = 0

    async def reset(self):
        log.info("Reset")

        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.clk, 5)
        self.dut.rst_n.value = 1

        self.queue = Queue()
        await RisingEdge(self.dut.clk)

    async def write(self, data):
        self.dut.i_wr_en.value = 1
        self.dut.i_wr_data.value = data

        await RisingEdge(self.dut.clk)

        self.dut.i_wr_en.value = 0

        if self.dut.o_wr_full.value == 0:
            self.queue.put(data)
            log.debug(f"Wrote {data}")
        else:
            log.debug("Full")

    async def read(self):
        self.dut.i_rd_en.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.i_rd_en.value = 0

        data = self.dut.o_rd_data.value.to_unsigned()

        if not self.queue.empty():
            q_data = self.queue.get()
            assert data == q_data, f"Data mismatch rtl: {data}, expected: {q_data}"
            log.debug(f"Read data matched: {data}")
        else:
            log.debug("Empty")

        return data

@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    tb = TB(dut)

    await tb.reset()
    
    for _ in range(5):
        val = random.randint(0, 0xFFFFFFFF)
        await tb.write(val)
        
    await ClockCycles(dut.clk, 1)
    
    for _ in range(5):
        await tb.read()
        
    log.info("R/W Test pass\n")
