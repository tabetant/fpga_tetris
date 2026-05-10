vlib work
vmap work work

vlog waves_tb.v
vsim work.waves_tb

# Inputs / controls
add wave -divider {Inputs}
add wave sim:/waves_tb/CLOCK_50
add wave sim:/waves_tb/resetn
add wave sim:/waves_tb/left_final
add wave sim:/waves_tb/right_final
add wave sim:/waves_tb/rot_final
add wave sim:/waves_tb/tick_gravity

# Game-ish internals
add wave -divider {Game internals}
add wave sim:/waves_tb/state
add wave sim:/waves_tb/next_state
add wave sim:/waves_tb/piece_x
add wave sim:/waves_tb/piece_y
add wave sim:/waves_tb/cur_x
add wave sim:/waves_tb/cur_y
add wave sim:/waves_tb/rot
add wave sim:/waves_tb/shape_id
add wave sim:/waves_tb/score
add wave sim:/waves_tb/move_accept
add wave sim:/waves_tb/have_action
add wave sim:/waves_tb/collide
add wave sim:/waves_tb/lock_phase

run 2 s
wave zoom full
