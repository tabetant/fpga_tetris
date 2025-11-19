# =========================================================
# Library + compile
# =========================================================
vlib work
vmap work work

# Compile all .v files in the directory
vlog *.v

# If your edge detector file really is named edgedetect.v.txt, include it explicitly:
# vlog edgedetect.v.txt

# Compile the testbench last (so default_nettype none from tetris is already in effect)
vlog tetris_tb.v

# =========================================================
# Simulate
# =========================================================
vsim -novopt work.tetris_tb

# =========================================================
# Waves
# =========================================================

# Top-level TB signals
add wave -divider {Top-level TB}
add wave sim:/tetris_tb/CLOCK_50
add wave sim:/tetris_tb/KEY
add wave sim:/tetris_tb/SW

# Inside tetris DUT
add wave -divider {tetris: reset & ticks}
add wave sim:/tetris_tb/dut/resetn
add wave sim:/tetris_tb/dut/tick_input
add wave sim:/tetris_tb/dut/tick_gravity

add wave -divider {tetris: PS2 pulses}
add wave sim:/tetris_tb/dut/left_ps2_pulse
add wave sim:/tetris_tb/dut/right_ps2_pulse
add wave sim:/tetris_tb/dut/rot_ps2_pulse

add wave -divider {tetris: frame-aligned inputs}
add wave sim:/tetris_tb/dut/left_final
add wave sim:/tetris_tb/dut/right_final
add wave sim:/tetris_tb/dut/rot_final

add wave -divider {tetris: board interface}
add wave sim:/tetris_tb/dut/board_we
add wave sim:/tetris_tb/dut/board_wx
add wave sim:/tetris_tb/dut/board_wy
add wave sim:/tetris_tb/dut/board_wdata
add wave sim:/tetris_tb/dut/board_rx
add wave sim:/tetris_tb/dut/board_ry
add wave sim:/tetris_tb/dut/board_rdata

add wave -divider {tetris: high-level game outputs}
add wave sim:/tetris_tb/dut/score
add wave sim:/tetris_tb/dut/cur_x
add wave sim:/tetris_tb/dut/cur_y
add wave sim:/tetris_tb/dut/move_accept

# Core game FSM inside gamelogic instance "GAME"
add wave -divider {GAME FSM & piece}
add wave sim:/tetris_tb/dut/GAME/state
add wave sim:/tetris_tb/dut/GAME/next_state
add wave sim:/tetris_tb/dut/GAME/piece_x
add wave sim:/tetris_tb/dut/GAME/piece_y
add wave sim:/tetris_tb/dut/GAME/rot
add wave sim:/tetris_tb/dut/GAME/shape_id
add wave sim:/tetris_tb/dut/GAME/lock_phase
add wave sim:/tetris_tb/dut/GAME/have_action
add wave sim:/tetris_tb/dut/GAME/collide

# No LEDR/VGA added here on purpose to keep things clean.

# =========================================================
# Run long enough to see interesting behavior
# =========================================================
run 2 s

wave zoom full
