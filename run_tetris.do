# compile
vlib work
vmap work work
vlog +define+SIM  \
  ticks.v flipflop.v synchronizer.v debouncer.v edgedetect.v \
  pending_event.v gamelogic.v tetris.v tb_tetris.v

# simulate (don't auto-exit)
vsim -novopt -onfinish stop work.tb_tetris

# minimal waves (keep it small)
add wave sim:/tb_tetris/CLOCK_50
add wave sim:/tb_tetris/KEY
add wave sim:/tb_tetris/DUT/in/tick_input
add wave sim:/tb_tetris/DUT/left
add wave sim:/tb_tetris/DUT/left_sync
add wave sim:/tb_tetris/DUT/left_level
add wave sim:/tb_tetris/DUT/left_pulse
add wave sim:/tb_tetris/DUT/left_final
add wave sim:/tb_tetris/DUT/GAME/state
add wave sim:/tb_tetris/DUT/GAME/move_accept

# run long enough to see frames
run 200 ms
