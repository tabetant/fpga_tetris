vlib work
vmap work work

# Compile (adjust filenames if needed)
vlog +acc \
  tetris_piece_offsets.v \
  gamelogic.v \
  tb_gamelogic_m2.v

vsim -voptargs=+acc work.tb_gamelogic_m2

# Waves
add wave -divider {CLOCK/RESET}
add wave -radix unsigned sim:/tb_gamelogic_m2/CLOCK_50
add wave sim:/tb_gamelogic_m2/resetn

add wave -divider {Inputs}
add wave sim:/tb_gamelogic_m2/left_final
add wave sim:/tb_gamelogic_m2/right_final
add wave sim:/tb_gamelogic_m2/rot_final
add wave sim:/tb_gamelogic_m2/tick_gravity

add wave -divider {DUT status}
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.state
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.rot
add wave -radix unsigned sim:/tb_gamelogic_m2/move_accept
add wave -radix unsigned sim:/tb_gamelogic_m2/cur_x
add wave -radix unsigned sim:/tb_gamelogic_m2/cur_y
add wave -radix unsigned sim:/tb_gamelogic_m2/LEDR

run -all
