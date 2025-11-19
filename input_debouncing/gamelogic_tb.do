# =========================================
# Library & compile
# =========================================
vlib work
vmap work work

# Only the modules gamelogic actually uses
vlog piece_offsets.v
vlog gamelogic.v
vlog gamelogic_tb.v

# =========================================
# Simulate
# =========================================
vsim -novopt work.gamelogic_tb

# =========================================
# Waves – only useful stuff (no X-storm)
# =========================================

# Testbench-level
add wave -divider {TB}
add wave sim:/gamelogic_tb/CLOCK_50
add wave sim:/gamelogic_tb/resetn
add wave sim:/gamelogic_tb/left_final
add wave sim:/gamelogic_tb/right_final
add wave sim:/gamelogic_tb/rot_final
add wave sim:/gamelogic_tb/tick_gravity

# Ports of gamelogic
add wave -divider {DUT ports}
add wave sim:/gamelogic_tb/dut/score
add wave sim:/gamelogic_tb/dut/cur_x
add wave sim:/gamelogic_tb/dut/cur_y
add wave sim:/gamelogic_tb/dut/move_accept
add wave sim:/gamelogic_tb/dut/board_we
add wave sim:/gamelogic_tb/dut/board_wx
add wave sim:/gamelogic_tb/dut/board_wy

# Internal FSM + piece coordinates
add wave -divider {FSM & Piece}
add wave sim:/gamelogic_tb/dut/state
add wave sim:/gamelogic_tb/dut/next_state
add wave sim:/gamelogic_tb/dut/piece_x
add wave sim:/gamelogic_tb/dut/piece_y
add wave sim:/gamelogic_tb/dut/rot
add wave sim:/gamelogic_tb/dut/shape_id
add wave sim:/gamelogic_tb/dut/lock_phase
add wave sim:/gamelogic_tb/dut/have_action
add wave sim:/gamelogic_tb/dut/collide

# (No LEDR or VGA here, on purpose.)

# =========================================
# Run long enough to see motion
# =========================================
run 2 s
wave zoom full
