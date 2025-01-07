# Register Definitions

| Address | Register Name       | Purpose                                                   |
|---------|----------------------|-----------------------------------------------------------|
| `0x00`  | Control              | Enables/disables UART and resets it.                      |
| `0x04`  | Mode                 | Sets baud rate, data bits, parity, etc.                   |
| `0x08`  | Status               | Channel status register 
| `0x0C`  | Config               | Indicates UART build configuration |
| `0x10`  | TXkk
| `0x14`  |
| `0x18`  |
| `0x1C`  |
| `0x20`  | Baud Rate Gen
| `0x24`  | Scratch              | Scratch register for 


# TODO
As time goes on, I might want to start doing my Tcl stuff all from withihin XSDB
instead of Vivado.
Also need to add some sort of syntax highlighting to Vim for Vivado T

## Channel Status Register (`UART_SR_OFFSET`)
Bits 15 to 0 for TX status
Bits 31 to 16 for RX status

0 - 

# Log
- Need to get data from the TX holding register into the FIFO
- I think it might be time to build a verification enviornment for the UART as
  we start adding software complexity

# Verification
Getting started on a verification suite for the UART core

Testbench Top

    Instantiates the DUT and all testbench components.
    Connects the DUT to the testbench via interfaces.

Environment

    The top-level container for all verification components (e.g., driver, monitor, scoreboard).

Interface

    Encapsulates the DUT's signals to enable modular and clean communication between the testbench and DUT.

Driver

    Generates stimulus for the DUT (e.g., register writes, data input).

Monitor

    Observes DUT outputs and extracts transactions for comparison.

Scoreboard

    Compares actual DUT behavior (observed by the monitor) with expected behavior.

Sequencer

    Supplies transaction sequences to the driver.


## Top Level Development
The top level verification module needs to contain:
- An AXI4-Lite interface of hte appropriate size
- Clocks and reset
- The DUT instance


