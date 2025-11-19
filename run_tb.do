; ---------- CLEAN-SLATE DOFILE ----------
transcript on
quietly vlib work
quietly vmap work work

; Compile
vlog +acc tetris_piece_offsets.v gamelogic.v tb_gamelogic_m2.v

; Start sim with full access
vsim -voptargs=+acc work.tb_gamelogic_m2

; Reset wave window
quietly .wave clear
quietly view wave
quietly wave zoom full

; Top-level TB
add wave -divider {TB Clocks & Reset}
add wave -radix unsigned sim:/tb_gamelogic_m2/CLOCK_50
add wave -radix binary  sim:/tb_gamelogic_m2/resetn

add wave -divider {TB Inputs to DUT}
add wave -radix binary  sim:/tb_gamelogic_m2/left_final
add wave -radix binary  sim:/tb_gamelogic_m2/right_final
add wave -radix binary  sim:/tb_gamelogic_m2/rot_final
add wave -radix binary  sim:/tb_gamelogic_m2/tick_gravity

add wave -divider {Board Stubs}
add wave -radix binary  sim:/tb_gamelogic_m2/board_rdata
add wave -radix unsigned sim:/tb_gamelogic_m2/board_rx
add wave -radix unsigned sim:/tb_gamelogic_m2/board_ry

add wave -divider {DUT -> TB Observables}
add wave -radix unsigned sim:/tb_gamelogic_m2/LEDR
add wave -radix unsigned sim:/tb_gamelogic_m2/score
add wave -radix unsigned sim:/tb_gamelogic_m2/cur_x
add wave -radix unsigned sim:/tb_gamelogic_m2/cur_y
add wave -radix binary  sim:/tb_gamelogic_m2/move_accept

; Dive into DUT internals (handy for M2)
add wave -divider {DUT State & Int}
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/state
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/next_state
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/rot
add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/new_rot
add wave -radix signed   sim:/tb_gamelogic_m2/DUT/dX
add wave -radix signed   sim:/tb_gamelogic_m2/DUT/dY
add wave -radix binary   sim:/tb_gamelogic_m2/DUT/have_action
add wave -radix binary   sim:/tb_gamelogic_m2/DUT/collide
add wave -radix binary   sim:/tb_gamelogic_m2/DUT/collide_bounds

; If these exist in your M2 version:
quietly catch { add wave -radix binary sim:/tb_gamelogic_m2/DUT/move_commit }
quietly catch { add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/piece_x }
quietly catch { add wave -radix unsigned sim:/tb_gamelogic_m2/DUT/piece_y }

; Run
run 2 ms
wave zoom full

; Don’t close on finish
quietly set NoQuitOnFinish 1
