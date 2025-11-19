transcript on
onerror {resume}
onbreak  {resume}

quietly catch {vdel -lib work -all}
vlib work
vmap work work

vlog -sv +acc tetris_piece_offsets.v
vlog -sv +acc gamelogic.v
vlog -sv +acc tb_gamelogic_m2.v

vsim -novopt -voptargs=+acc work.tb_gamelogic_m2

quietly .wave clear
view wave

add wave sim:/tb_gamelogic_m2/CLOCK_50
add wave sim:/tb_gamelogic_m2/resetn
add wave sim:/tb_gamelogic_m2/left_final
add wave sim:/tb_gamelogic_m2/right_final
add wave sim:/tb_gamelogic_m2/rot_final
add wave sim:/tb_gamelogic_m2/tick_gravity

add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/state
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/rot
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/piece_x
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/piece_y
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/cur_x
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/cur_y
add wave sim:/tb_gamelogic_m2/DUT/have_action
add wave sim:/tb_gamelogic_m2/DUT/collide
add wave sim:/tb_gamelogic_m2/DUT/move_accept

run 2 s
wave zoom full
