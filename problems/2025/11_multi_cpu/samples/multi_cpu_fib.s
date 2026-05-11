#
# Core 0: generate Fibonacci numbers and push them into FIFO.
# Core 1: pop Fibonacci numbers from FIFO and write them to 7-seg MMIO.
#
# MMIO byte addresses:
#   0x10 : FIFO data
#   0x14 : FIFO full     ; valid for core 0
#   0x18 : FIFO empty    ; valid for core 1
#   0x1c : CORE_ID       ; 0 for core 0, 1 for core 1
#   0x20 : 7-seg data    ; valid for core 1

.text
.globl _start
_start:
    addi x1,  x0, 0x1c        # x1 = CORE_ID address
    lw   x2,  0(x1)           # x2 = CORE_ID
    addi x3,  x0, 1
    beq  x2,  x3, core1_main  # CORE_ID == 1 -> rx/disp
    jal  x0,  core0_main      # CORE_ID == 0 -> tx

# -------------------------------------------------------------------------
# Core 0: Fibonacci producer
# -------------------------------------------------------------------------
core0_main:
    addi x10, x0, 0x10        # FIFO data address
    addi x11, x0, 0x14        # FIFO full address
    addi x12, x0, 0           # fib a
    addi x13, x0, 1           # fib b
    addi x14, x0, 16          # number of terms to send

core0_tx_loop:
core0_wait_not_full:
    lw   x15, 0(x11)          # x15 = fifo_full
    bne  x15, x0, core0_wait_not_full

    sw   x12, 0(x10)          # push current Fibonacci value

    add  x16, x12, x13        # next = a + b
    addi x12, x13, 0          # a = b
    addi x13, x16, 0          # b = next
    addi x14, x14, -1
    bne  x14, x0, core0_tx_loop

core0_done:
    jal  x0, core0_done

# -------------------------------------------------------------------------
# Core 1: Fibonacci consumer
# Reads FIFO and writes each received value to the 7-seg data register.
# -------------------------------------------------------------------------
core1_main:
    addi x10, x0, 0x10        # FIFO data address
    addi x11, x0, 0x18        # FIFO empty address
    addi x12, x0, 0x20        # 7-seg data address
    addi x13, x0, 16          # number of terms to receive

core1_rx_loop:
core1_wait_not_empty:
    lw   x15, 0(x11)          # x15 = fifo_empty
    bne  x15, x0, core1_wait_not_empty

    lw   x16, 0(x10)          # pop FIFO data
    sw   x16, 0(x12)          # display low 16 bits

    # Visible delay before consuming the next value. 0x1000000 loop iterations
    # is long enough for the 7-seg display on FPGA.
    lui  x17, 0x1000
core1_delay:
    addi x17, x17, -1
    bne  x17, x0, core1_delay

    addi x13, x13, -1
    bne  x13, x0, core1_rx_loop

core1_done:
    jal  x0, core1_done
