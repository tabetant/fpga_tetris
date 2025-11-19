# Clean & setup
vlib work
vmap work work

# Compile everything (adjust if you prefer explicit file list)
vlog *.v

# Simulate the testbench
vsim -novopt work.tetris_tb

# -----------------------------
# Wave configuration
# -----------------------------

# Top-level
add wave -divider {Top-level}
add wave sim:/tetris_tb/CLOCK_50
add wave sim:/tetris_tb/KEY
add wave sim:/tetris_tb/SW

# Ticks and move pulses (from tetris.v)
add wave -divider {Ticks & Inputs}
add wave sim:/tetris_tb/dut/resetn
add wave sim:/tetris_tb/dut/tick_input
add wave sim:/tetris_tb/dut/tick_gravity
add wave sim:/tetris_tb/dut/left_final
add wave sim:/tetris_tb/dut/right_final
add wave sim:/tetris_tb/dut/rot_final

# Game FSM + piece coordinates (from gamelogic.v, instance GAME)
add wave -divider {Game FSM}
add wave sim:/tetris_tb/dut/GAME/state
add wave sim:/tetris_tb/dut/GAME/next_state
add wave sim:/tetris_tb/dut/GAME/piece_x
add wave sim:/tetris_tb/dut/GAME/piece_y
add wave sim:/tetris_tb/dut/GAME/rot
add wave sim:/tetris_tb/dut/GAME/shape_id
add wave sim:/tetris_tb/dut/GAME/lock_phase
add wave sim:/tetris_tb/dut/GAME/have_action
add wave sim:/tetris_tb/dut/GAME/collide
add wave sim:/tetris_tb/dut/GAME/move_accept

# Useful extras
add wave -divider {Current cell / score}
add wave sim:/tetris_tb/dut/cur_x
add wave sim:/tetris_tb/dut/cur_y
add wave sim:/tetris_tb/dut/score

# No LEDR, no VGA, no clutter :)

# Run for 2 seconds of simulation time
run 2 s

wave zoom full
