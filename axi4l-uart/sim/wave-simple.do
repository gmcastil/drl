onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/clk
add wave -noupdate /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/rstn
add wave -noupdate -group {AXI4-Lite Interface} -divider {Write Request}
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_awaddr
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_awvalid
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_awready
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_wdata
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_wstrb
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_wvalid
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_wready
add wave -noupdate -group {AXI4-Lite Interface} -divider {Write Response}
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_bvalid
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_bready
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_bresp
add wave -noupdate -group {AXI4-Lite Interface} -divider {Read Request}
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_araddr
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_arvalid
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_arready
add wave -noupdate -group {AXI4-Lite Interface} -divider {Read Response}
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_rdata
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_rvalid
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_rready
add wave -noupdate -group {AXI4-Lite Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/s_axi_rresp
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_addr
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_wdata
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_wren
add wave -noupdate -expand -group {Register Interface} -radix binary /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_be
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_rdata
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_req
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_ack
add wave -noupdate -expand -group {Register Interface} /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/reg_err
add wave -noupdate -radix unsigned /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/wr_txn_cnt
add wave -noupdate -radix unsigned /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/wr_err_cnt
add wave -noupdate -radix unsigned /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/rd_txn_cnt
add wave -noupdate -radix unsigned /top/uart_wrapper_i0/uart_top_i0/axi4l_regs_i0/rd_err_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {158202 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1275750 ps}
