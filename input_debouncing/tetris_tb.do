# =========================================
# Library & compile
# =========================================
vlib work
vmap work work

# 1) Compile core logic modules (no `default_nettype none` at top)
#    Add any other lab/course files *without* default_nettype here.
vlog piece_offsets.v
vlog pending_event.v
vlog debouncer.v
vlog synchronizer.v
vlog gamelogic.v

# If you have tick_i.v, tick_g.v, PS2_Interface.v, vga_adapter.v, etc.,
# compile them here as well, BEFORE render/tetris:
# vlog tick_i.v
# vlog tick_g.v
# vlog PS2_Interface.v
# vlog vga_adapter.v

# 2) Modules that start with `default_nettype none` – compile these late
vlog render.v
vlog tetris.v

# 3) Testbench (has `default_nettype wire` at the top)
vlog tetris_tb.v

# =========================================
# Simulate testbench
# =========================================
vsim -novopt work.tetris_tb

# =========================================
# Waves – only important stuff
# =========================================

# Top-level TB signals
add wave -divider {TB top}
add wave sim:/tetris_tb/CLOCK_50
add wave sim:/tetris_tb/KEY
add wave sim:/tetris_tb/SW

# Inside tetris
add wave -divider {tetris: reset & ticks}
add wave sim:/tetris_tb/dut/resetn
add wave sim:/tetris_tb/dut/tick_input
add wave sim:/tetris_tb/dut/tick_gravity

add wave -divider {tetris: PS/2 pulses}
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

add wave -divider {tetris: game outputs}
add wave sim:/tetris_tb/dut/score
add wave sim:/tetris_tb/dut/cur_x
add wave sim:/tetris_tb/dut/cur_y
add wave sim:/tetris_tb/dut/move_accept

# Core game FSM & piece inside gamelogic instance "GAME"
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

# No LEDR/VGA here by design → no clutter.

# =========================================
# Run for 2 seconds
# =========================================
run 2 s
wave zoom full
