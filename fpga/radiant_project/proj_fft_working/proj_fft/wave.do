onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_fftfull/dut/clk
add wave -noupdate /testbench_fftfull/dut/reset
add wave -noupdate /testbench_fftfull/dut/fft_load
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/mem_write0
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/mem_write1
add wave -noupdate -radix hexadecimal /testbench_fftfull/dut/fft/addctrl_inst/r0_add_a
add wave -noupdate -radix hexadecimal /testbench_fftfull/dut/fft/addctrl_inst/r0_add_b
add wave -noupdate /testbench_fftfull/dut/fft/ram0_a/wr_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_a/wr_data_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_b/wr_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_b/wr_data_i
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/r1_add_a
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/r1_add_b
add wave -noupdate /testbench_fftfull/dut/fft_start
add wave -noupdate /testbench_fftfull/dut/noted
add wave -noupdate /testbench_fftfull/dut/fft_done
add wave -noupdate /testbench_fftfull/dut/frequency
add wave -noupdate /testbench_fftfull/dut/note_dec
add wave -noupdate /testbench_fftfull/dut/note
add wave -noupdate /testbench_fftfull/dut/fft/ram0_a/rd_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_a/wr_en_i
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fft/ram0_a/rd_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_a/rd_data_o
add wave -noupdate -radix hexadecimal /testbench_fftfull/dut/fft/ram0_b/rd_data_o
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fft/ram0_b/rd_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_b/rd_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram0_b/wr_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/rd_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/wr_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/wr_data_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/wr_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/rd_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_a/rd_data_o
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/rd_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/wr_en_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/wr_data_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/wr_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/rd_addr_i
add wave -noupdate /testbench_fftfull/dut/fft/ram1_b/rd_data_o
add wave -noupdate /testbench_fftfull/dut/fft/twiddle_lut/tw_add
add wave -noupdate -radix decimal /testbench_fftfull/dut/fft/addctrl_inst/addgen/fft_level
add wave -noupdate -radix decimal /testbench_fftfull/dut/fft/addctrl_inst/addgen/fft_bf
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/bf_enable
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/fft_enable
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/bf_enable
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/real_a
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/real_b
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_a
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_b
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/real_tw
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_tw
add wave -noupdate -radix hexadecimal /testbench_fftfull/dut/fft/butterfly_inst/real_ap
add wave -noupdate -radix hexadecimal /testbench_fftfull/dut/fft/butterfly_inst/real_bp
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_ap
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_bp
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/real_btw
add wave -noupdate /testbench_fftfull/dut/fft/butterfly_inst/img_btw
add wave -noupdate /testbench_fftfull/dut/fft/addctrl_inst/read_sel
add wave -noupdate /testbench_fftfull/dut/fft/delay_1cyc
add wave -noupdate /testbench_fftfull/dut/fft/delay_2cyc
add wave -noupdate /testbench_fftfull/dut/fft/delay
add wave -noupdate /testbench_fftfull/dut/fftdec/dout
add wave -noupdate /testbench_fftfull/dut/fftdec/fft_result
add wave -noupdate -radix decimal /testbench_fftfull/dut/fftdec/real_v
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/img
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/frequency
add wave -noupdate /testbench_fftfull/dut/fftdec/note_dec
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/magnitude_sq
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/magnitude_max
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/k
add wave -noupdate -radix unsigned /testbench_fftfull/dut/fftdec/k_max
add wave -noupdate -radix decimal /testbench_fftfull/dut/fft/addctrl_inst/fft_idx
add wave -noupdate /testbench_fftfull/dut/fft/out_a
add wave -noupdate /testbench_fftfull/dut/fft/out_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11555729 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 276
configure wave -valuecolwidth 107
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {13243243 ps} {13390901 ps}
