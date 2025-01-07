# Hardware location of UART
set UART_OFFSET 0x80000000

# Register numbers taken from the `uart_pkg.vhd` file
set CTRL_REG 0
set MODE_REG 1
set STATUS_REG 2
set CONFIG_REG 3
set BAUD_GEN_STATUS_REG 6
set BAUD_GEN_CTRL_REG 7
set SCRATCH_REG 15

# Dump out the properties of a specific JTAG to AXI core
proc display_hw_axi_properties {jtag_axi_core} {
    set properties [list_property "${jtag_axi_core}"]

    puts "== JTAG to AXI Core =="
    foreach prop "${properties}" {
        set value [get_property "${prop}" "${jtag_axi_core}"]
        puts [format "%-30s %s" "${prop}" "${value}"] 
    }
}

# Write a UART register and check the response. Returns nothing.
proc uart_write_reg {reg val} {
    # Do a bit of arithmetic to get the AXI address of the register from the
    # register number and the AXI offset
    global UART_OFFSET
    # Convert the register number to register offset
    set reg_offset [expr { "${reg}" * 4 }]
    set wr_addr [expr { "${UART_OFFSET}" + "${reg_offset}" }]
    # This extra format step is required because the command that creates the
    # hardware transaction assumes addresses are in a hexadecimal format
    set wr_addr [format 0x%x "${wr_addr}"]

    # Reset the JTAG to AXI core so that it has a well-defined state
    set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
    reset_hw_axi ${jtag_axi_core}

    # Create a new JTAG to AXI write transaction and run it (we force it to
    # overwrite any existing ones)
    create_hw_axi_txn \
        -force \
        -type WRITE \
        -address "${wr_addr}" \
        -len 1 \
        -data "${val}" \
        wr_txn "${jtag_axi_core}"
    run_hw_axi -quiet [get_hw_axi_txns wr_txn]

    # And then check the result
    set bresp [get_property STATUS.BRESP  "${jtag_axi_core}"]
    if {"${bresp}" != "OKAY"} {
        error "${bresp}"
    }
}

# Read a UART register and check the response. Returns 32-bit read value in hex.
proc uart_read_reg {reg} {
    # Do a bit of arithmetic to get the AXI address of the register from the
    # register number and the AXI offset
    global UART_OFFSET
    # Convert the register number to register offset
    set reg_offset [expr { "${reg}" * 4 }]
    set rd_addr [expr { "${UART_OFFSET}" + "${reg_offset}" }]
    # This extra format step is required because the command that creates the
    # hardware transaction assumes addresses are in a hexadecimal format
    set rd_addr [format 0x%x "${rd_addr}"]

    # Reset the JTAG to AXI core so that it has a well-defined state
    set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
    reset_hw_axi ${jtag_axi_core}

    # Create a new JTAG to AXI write transaction and run it (we force it to
    # overwrite any existing ones)
    create_hw_axi_txn \
        -force \
        -type READ \
        -address "${rd_addr}" \
        -len 1 \
        rd_txn "${jtag_axi_core}"
    run_hw_axi -quiet [get_hw_axi_txns rd_txn]

    set rresp [get_property STATUS.RRESP "${jtag_axi_core}"]
    if {"${rresp}" != "OKAY"} {
        error "${rresp}"
    } else {
        # Vivado returns this implicitly as a hex value, so we prepend 0x to it
        return 0x[get_property DATA [get_hw_axi_txns rd_txn]]
    }
}

# Check JTAG to AXI master status before getting started
set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
display_hw_axi_properties "${jtag_axi_core}"

# Check scratch register
set wr_data 0x12341234
uart_write_reg "${SCRATCH_REG}" "${wr_data}"
set rd_data [uart_read_reg "${SCRATCH_REG}"]
if {"${wr_data}" != "${rd_data}"} {
    puts "Error: Failed to write scratch register. Expected ${wr_data} but received ${rd_data}"
} else {
    puts "Scratch register check successful"
}

set wr_data 0xffffffff
uart_write_reg "${BAUD_GEN_CTRL_REG}" "${wr_data}"
set rd_data [uart_read_reg "${BAUD_GEN_STATUS_REG}"]
puts "READ: ${rd_data}"
set rd_data [uart_read_reg "${BAUD_GEN_STATUS_REG}"]
puts "READ: ${rd_data}"

puts "Reading build configuration"
set rd_data [uart_read_reg "${CONFIG_REG}"]
puts "READ: ${rd_data}"
