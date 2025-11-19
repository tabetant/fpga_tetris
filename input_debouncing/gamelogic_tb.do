vlib work
vmap work work

vlog gamelogic_tb.v
vsim work.gamelogic_tb

# Inputs / control
add wave -divider {Inputs}
add wave sim:/gamelogic_tb/CLOCK_50
add wave sim:/gamelogic_tb/resetn
add wave sim:/gamelogic_tb/left_final
add wave sim:/gamelogic_tb/right_final
add wave sim:/gamelogic_tb/rot_final
add wave sim:/gamelogic_tb/tick_gravity

# Game-style internal signals
add wave -divider {Game internals}
add wave sim:/gamelogic_tb/state
add wave sim:/gamelogic_tb/next_state
add wave sim:/gamelogic_tb/piece_x
add wave sim:/gamelogic_tb/piece_y
add wave sim:/gamelogic_tb/cur_x
add wave sim:/gamelogic_tb/cur_y
add wave sim:/gamelogic_tb/rot
add wave sim:/gamelogic_tb/shape_id
add wave sim:/gamelogic_tb/score
add wave sim:/gamelogic_tb/move_accept
add wave sim:/gamelogic_tb/have_action
add wave sim:/gamelogic_tb/collide
add wave sim:/gamelogic_tb/lock_phase

run 2 s
wave zoom full
