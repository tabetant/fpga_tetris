vlib work
vmap work work

vlog fake_gamelogic_tb.v
vsim work.fake_gamelogic_tb

# Inputs / control
add wave -divider {Inputs}
add wave sim:/fake_gamelogic_tb/CLOCK_50
add wave sim:/fake_gamelogic_tb/resetn
add wave sim:/fake_gamelogic_tb/left_final
add wave sim:/fake_gamelogic_tb/right_final
add wave sim:/fake_gamelogic_tb/rot_final
add wave sim:/fake_gamelogic_tb/tick_gravity

# Game-style internal signals
add wave -divider {Game internals}
add wave sim:/fake_gamelogic_tb/state
add wave sim:/fake_gamelogic_tb/next_state
add wave sim:/fake_gamelogic_tb/piece_x
add wave sim:/fake_gamelogic_tb/piece_y
add wave sim:/fake_gamelogic_tb/cur_x
add wave sim:/fake_gamelogic_tb/cur_y
add wave sim:/fake_gamelogic_tb/rot
add wave sim:/fake_gamelogic_tb/shape_id
add wave sim:/fake_gamelogic_tb/score
add wave sim:/fake_gamelogic_tb/move_accept
add wave sim:/fake_gamelogic_tb/have_action
add wave sim:/fake_gamelogic_tb/collide
add wave sim:/fake_gamelogic_tb/lock_phase

run 2 s
wave zoom full
