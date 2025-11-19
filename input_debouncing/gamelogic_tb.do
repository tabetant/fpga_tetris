# =========================================
# Library & compile
# =========================================
vlib work
vmap work work

# Only what gamelogic actually needs
vlog piece_offsets.v
vlog gamelogic.v
vlog gamelogic_tb.v

# =========================================
# Simulate
# =========================================
vsim -novopt work.gamelogic_tb

# =========================================
# Waves – only non-junky signals
# =========================================

# Testbench / inputs
add wave -divider {TB / inputs}
add wave sim:/gamelogic_tb/CLOCK_50
add wave sim:/gamelogic_tb/resetn
add wave sim:/gamelogic_tb/left_final
add wave sim:/gamelogic_tb/right_final
add wave sim:/gamelogic_tb/rot_final
add wave sim:/gamelogic_tb/tick_gravity
add wave sim:/gamelogic_tb/board_rdata

# DUT high-level ports
add wave -divider {DUT ports}
add wave sim:/gamelogic_tb/dut/state
add wave sim:/gamelogic_tb/dut/next_state
add wave sim:/gamelogic_tb/dut/piece_x
add wave sim:/gamelogic_tb/dut/piece_y
add wave sim:/gamelogic_tb/dut/rot
add wave sim:/gamelogic_tb/dut/shape_id
add wave sim:/gamelogic_tb/dut/cur_x
add wave sim:/gamelogic_tb/dut/cur_y
add wave sim:/gamelogic_tb/dut/score
add wave sim:/gamelogic_tb/dut/move_accept

# Board write activity (optional, but useful)
add wave -divider {Board writes}
add wave sim:/gamelogic_tb/dut/board_we
add wave sim:/gamelogic_tb/dut/board_wx
add wave sim:/gamelogic_tb/dut/board_wy
add wave sim:/gamelogic_tb/dut/board_wdata

# =========================================
# Run long enough (2 s)
# =========================================
run 2 s
wave zoom full
