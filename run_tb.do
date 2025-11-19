vlib work
vmap work work

# Compile (strict Verilog-2001)
vlog +acc \
  tetris_piece_offsets.v \
  gamelogic.v \
  tb_gamelogic_m2.v

# Optimize but keep access to internals
vsim -voptargs=+acc work.tb_gamelogic_m2

# Optional: log everything so nothing is “dead”
log -r /*

# Wave setup (you can trim if too chatty)
add wave -divider {CLK/RESET}
add wave -radix unsigned sim:/tb_gamelogic_m2/CLOCK_50
add wave -radix unsigned sim:/tb_gamelogic_m2/resetn

add wave -divider {Inputs}
add wave sim:/tb_gamelogic_m2/left_final
add wave sim:/tb_gamelogic_m2/right_final
add wave sim:/tb_gamelogic_m2/rot_final
add wave sim:/tb_gamelogic_m2/tick_gravity

add wave -divider {DUT}
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.state
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.rot
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.cur_x
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.cur_y
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.score
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT.move_accept
add wave -radix unsigned sim:/tb_gamelogic_m2/LEDR

# Run full 2 seconds (timescale 1ns/1ps => 2 s = 2e9 ns)
run 2 s

# Keep the sim open at the end
# (remove the next line if you prefer it to auto-quit)
quietly set NoQuitOnFinish 1
