# =========================================================
# Library + compile
# =========================================================
vlib work
vmap work work

# Compile design + testbench
# (Adjust paths if your files are in another folder)
vlog gamelogic.v
vlog piece_offsets.v
vlog gamelogic_tb.v

# =========================================================
# Simulate
# =========================================================
vsim -novopt work.gamelogic_tb

# =========================================================
# Waves
# =========================================================

# Top-level TB stuff
add wave -divider {Clock & Reset}
add wave sim:/gamelogic_tb/CLOCK_50
add wave sim:/gamelogic_tb/resetn

add wave -divider {Inputs}
add wave sim:/gamelogic_tb/left_final
add wave sim:/gamelogic_tb/right_final
add wave sim:/gamelogic_tb/rot_final
add wave sim:/gamelogic_tb/tick_gravity

add wave -divider {High-level Outputs}
add wave sim:/gamelogic_tb/score
add wave sim:/gamelogic_tb/cur_x
add wave sim:/gamelogic_tb/cur_y
add wave sim:/gamelogic_tb/move_accept

# Internal FSM + piece info inside gamelogic
add wave -divider {FSM & Piece (dut)}
add wave sim:/gamelogic_tb/dut/state
add wave sim:/gamelogic_tb/dut/next_state
add wave sim:/gamelogic_tb/dut/piece_x
add wave sim:/gamelogic_tb/dut/piece_y
add wave sim:/gamelogic_tb/dut/rot
add wave sim:/gamelogic_tb/dut/shape_id
add wave sim:/gamelogic_tb/dut/lock_phase
add wave sim:/gamelogic_tb/dut/have_action
add wave sim:/gamelogic_tb/dut/collide

# (Optional) Board write coordinates if you want them, but commented to avoid clutter:
# add wave sim:/gamelogic_tb/dut/board_wx
# add wave sim:/gamelogic_tb/dut/board_wy
# add wave sim:/gamelogic_tb/dut/board_we

# No LEDR/VGA here on purpose -> clean screen.

# =========================================================
# Run long enough to see lots of movement
# =========================================================
run 2 s

wave zoom full
